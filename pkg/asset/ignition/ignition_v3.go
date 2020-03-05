// +build okd

package ignition

import (
	"encoding/json"
	"fmt"
	"path/filepath"

	"github.com/coreos/ignition/config/util"
	igntypes3 "github.com/coreos/ignition/v2/config/v3_0/types"
	mcfgv1 "github.com/openshift/machine-config-operator/pkg/apis/machineconfiguration.openshift.io/v1"
	"github.com/pkg/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	"github.com/openshift/installer/pkg/asset/openshiftinstall"

	"github.com/openshift/installer/pkg/asset"
	"github.com/vincent-petithory/dataurl"
)

// IgnConfig is ignition v3 Config
type IgnConfig igntypes3.Config

// Dropin in an abstraction over igntypes2.SystemdDropin
type Dropin struct {
	Name     string
	Contents string
}

// FilesFromAsset creates ignition files for each of the files in the specified
// asset.
func FilesFromAsset(pathPrefix string, username string, mode int, asset asset.WritableAsset) []igntypes3.File {
	var files []igntypes3.File
	for _, f := range asset.Files() {
		files = append(files, FileFromBytes(filepath.Join(pathPrefix, f.Filename), username, mode, f.Data))
	}
	return files
}

// FileFromString creates an ignition-config file with the given contents.
func FileFromString(path string, username string, mode int, contents string) igntypes3.File {
	return FileFromBytes(path, username, mode, []byte(contents))
}

// FileFromBytes creates an ignition-config file with the given contents.
func FileFromBytes(path string, username string, mode int, contents []byte) igntypes3.File {
	contentsString := dataurl.EncodeBytes(contents)
	return igntypes3.File{
		Node: igntypes3.Node{
			Path: path,
			User: igntypes3.NodeUser{
				Name: &username,
			},
		},
		FileEmbedded1: igntypes3.FileEmbedded1{
			Mode: &mode,
			Contents: igntypes3.FileContents{
				Source: &contentsString,
			},
		},
	}
}

// PointerIgnitionConfig generates a config which references the remote config
// served by the machine config server.
func PointerIgnitionConfig(url string, rootCA []byte) *IgnConfig {
	return &IgnConfig{
		Ignition: igntypes3.Ignition{
			Version: igntypes3.MaxVersion.String(),
			Config: igntypes3.IgnitionConfig{
				Merge: []igntypes3.ConfigReference{{
					Source: &url,
				}},
			},
			Security: igntypes3.Security{
				TLS: igntypes3.TLS{
					CertificateAuthorities: []igntypes3.CaReference{{
						Source: dataurl.EncodeBytes(rootCA),
					}},
				},
			},
		},
	}
}

// ForAuthorizedKeys creates the MachineConfig to set the authorized key for `core` user.
func ForAuthorizedKeys(key string, role string) *mcfgv1.MachineConfig {
	return &mcfgv1.MachineConfig{
		TypeMeta: metav1.TypeMeta{
			APIVersion: mcfgv1.SchemeGroupVersion.String(),
			Kind:       "MachineConfig",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name: fmt.Sprintf("99-%s-ssh", role),
			Labels: map[string]string{
				"machineconfiguration.openshift.io/role": role,
			},
		},
		Spec: mcfgv1.MachineConfigSpec{
			Config: igntypes3.Config{
				Ignition: igntypes3.Ignition{
					Version: igntypes3.MaxVersion.String(),
				},
				Passwd: igntypes3.Passwd{
					Users: []igntypes3.PasswdUser{{
						Name: "core", SSHAuthorizedKeys: []igntypes3.SSHAuthorizedKey{igntypes3.SSHAuthorizedKey(key)},
					}},
				},
			},
		},
	}
}

// ForFIPSEnabled creates the MachineConfig to enable FIPS.
// See also https://github.com/openshift/machine-config-operator/pull/889
func ForFIPSEnabled(role string) *mcfgv1.MachineConfig {
	return &mcfgv1.MachineConfig{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "machineconfiguration.openshift.io/v1",
			Kind:       "MachineConfig",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name: fmt.Sprintf("99-%s-fips", role),
			Labels: map[string]string{
				"machineconfiguration.openshift.io/role": role,
			},
		},
		Spec: mcfgv1.MachineConfigSpec{
			Config: igntypes3.Config{
				Ignition: igntypes3.Ignition{
					Version: igntypes3.MaxVersion.String(),
				},
			},
			FIPS: true,
		},
	}
}

// ForHyperthreadingDisabled creates the MachineConfig to disable hyperthreading.
// RHCOS ships with pivot.service that uses the `/etc/pivot/kernel-args` to override the kernel arguments for hosts.
func ForHyperthreadingDisabled(role string) *mcfgv1.MachineConfig {
	return &mcfgv1.MachineConfig{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "machineconfiguration.openshift.io/v1",
			Kind:       "MachineConfig",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name: fmt.Sprintf("99-%s-disable-hyperthreading", role),
			Labels: map[string]string{
				"machineconfiguration.openshift.io/role": role,
			},
		},
		Spec: mcfgv1.MachineConfigSpec{
			Config: igntypes3.Config{
				Ignition: igntypes3.Ignition{
					Version: igntypes3.MaxVersion.String(),
				},
				Storage: igntypes3.Storage{
					Files: []igntypes3.File{
						FileFromString("/etc/pivot/kernel-args", "root", 0600, "ADD nosmt"),
					},
				},
			},
		},
	}
}

// InjectInstallInfo adds information about the installer and its invoker as a
// ConfigMap to the provided bootstrap Ignition config.
func InjectInstallInfo(bootstrap []byte) (string, error) {
	config := &IgnConfig{}
	if err := json.Unmarshal(bootstrap, &config); err != nil {
		return "", errors.Wrap(err, "failed to unmarshal bootstrap Ignition config")
	}

	cm, err := openshiftinstall.CreateInstallConfigMap("openshift-install")
	if err != nil {
		return "", errors.Wrap(err, "failed to generate openshift-install config")
	}

	config.Storage.Files = append(config.Storage.Files, FileFromString("/opt/openshift/manifests/openshift-install.yaml", "root", 0644, cm))

	ign, err := json.Marshal(config)
	if err != nil {
		return "", errors.Wrap(err, "failed to marshal bootstrap Ignition config")
	}

	return string(ign), nil
}

// GenerateMinimalConfig returns a minimal ignition v2 config
func GenerateMinimalConfig() *IgnConfig {
	return &IgnConfig{
		Ignition: igntypes3.Ignition{
			Version: igntypes3.MaxVersion.String(),
		},
	}
}

// AddSSHKey returns a minimal ignition v2 config
func (c *IgnConfig) AddSSHKey(sshKey string) {
	c.Passwd.Users = append(
		c.Passwd.Users,
		igntypes3.PasswdUser{Name: "core", SSHAuthorizedKeys: []igntypes3.SSHAuthorizedKey{igntypes3.SSHAuthorizedKey(sshKey)}},
	)
}

// AddSystemdUnit appends contents in Ignition config
func (c *IgnConfig) AddSystemdUnit(name string, contents string, enabled bool) {
	unit := igntypes3.Unit{
		Name:     name,
		Contents: &contents,
	}
	if enabled {
		unit.Enabled = util.BoolToPtr(true)
	}
	c.Systemd.Units = append(c.Systemd.Units, unit)

}

// AddSystemdDropins appends systemd dropins in the config
func (c *IgnConfig) AddSystemdDropins(name string, children []Dropin, enabled bool) {
	dropins := []igntypes3.Dropin{}
	for _, childInfo := range children {

		dropins = append(dropins, igntypes3.Dropin{
			Name:     childInfo.Name,
			Contents: &childInfo.Contents,
		})
	}
	unit := igntypes3.Unit{
		Name:    name,
		Dropins: dropins,
	}
	if enabled {
		unit.Enabled = util.BoolToPtr(true)
	}
	c.Systemd.Units = append(c.Systemd.Units, unit)
}

// ReplaceOrAppend is a function which ensures duplicate files are not added in the file list
func ReplaceOrAppend(files []igntypes3.File, file igntypes3.File) []igntypes3.File {
	for i, f := range files {
		if f.Node.Path == file.Node.Path {
			files[i] = file
			return files
		}
	}
	files = append(files, file)
	return files
}
