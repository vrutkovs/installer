// +build !okd

package ignition

import (
	"encoding/json"
	"fmt"
	"path/filepath"

	"github.com/coreos/ignition/config/util"
	igntypes2 "github.com/coreos/ignition/config/v2_2/types"
	"github.com/pkg/errors"

	mcfgv1 "github.com/openshift/machine-config-operator/pkg/apis/machineconfiguration.openshift.io/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	"github.com/openshift/installer/pkg/asset/openshiftinstall"

	"github.com/openshift/installer/pkg/asset"
	"github.com/vincent-petithory/dataurl"
)

// IgnConfig is ignition v2 Config
type IgnConfig igntypes2.Config

// Dropin in an abstraction over igntypes2.SystemdDropin
type Dropin struct {
	Name     string
	Contents string
}

// FilesFromAsset creates ignition files for each of the files in the specified
// asset.
func FilesFromAsset(pathPrefix string, username string, mode int, asset asset.WritableAsset) []igntypes2.File {
	var files []igntypes2.File
	for _, f := range asset.Files() {
		files = append(files, FileFromBytes(filepath.Join(pathPrefix, f.Filename), username, mode, f.Data))
	}
	return files
}

// FileFromString creates an ignition-config file with the given contents.
func FileFromString(path string, username string, mode int, contents string) igntypes2.File {
	return FileFromBytes(path, username, mode, []byte(contents))
}

// FileFromBytes creates an ignition-config file with the given contents.
func FileFromBytes(path string, username string, mode int, contents []byte) igntypes2.File {
	return igntypes2.File{
		Node: igntypes2.Node{
			Filesystem: "root",
			Path:       path,
			User: &igntypes2.NodeUser{
				Name: username,
			},
		},
		FileEmbedded1: igntypes2.FileEmbedded1{
			Mode: &mode,
			Contents: igntypes2.FileContents{
				Source: dataurl.EncodeBytes(contents),
			},
		},
	}
}

// PointerIgnitionConfig generates a config which references the remote config
// served by the machine config server.
func PointerIgnitionConfig(url string, rootCA []byte) *IgnConfig {
	return &IgnConfig{
		Ignition: igntypes2.Ignition{
			Version: igntypes2.MaxVersion.String(),
			Config: igntypes2.IgnitionConfig{
				Append: []igntypes2.ConfigReference{{
					Source: url,
				}},
			},
			Security: igntypes2.Security{
				TLS: igntypes2.TLS{
					CertificateAuthorities: []igntypes2.CaReference{{
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
			Config: igntypes2.Config{
				Ignition: igntypes2.Ignition{
					Version: igntypes2.MaxVersion.String(),
				},
				Passwd: igntypes2.Passwd{
					Users: []igntypes2.PasswdUser{{
						Name: "core", SSHAuthorizedKeys: []igntypes2.SSHAuthorizedKey{igntypes2.SSHAuthorizedKey(key)},
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
			Config: igntypes2.Config{
				Ignition: igntypes2.Ignition{
					Version: igntypes2.MaxVersion.String(),
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
			Config: igntypes2.Config{
				Ignition: igntypes2.Ignition{
					Version: igntypes2.MaxVersion.String(),
				},
				Storage: igntypes2.Storage{
					Files: []igntypes2.File{
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
	config := &igntypes2.Config{}
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
		Ignition: igntypes2.Ignition{
			Version: igntypes2.MaxVersion.String(),
		},
	}
}

// AddSSHKey returns a minimal ignition v2 config
func (c *IgnConfig) AddSSHKey(sshKey string) {
	c.Passwd.Users = append(
		c.Passwd.Users,
		igntypes2.PasswdUser{Name: "core", SSHAuthorizedKeys: []igntypes2.SSHAuthorizedKey{igntypes2.SSHAuthorizedKey(sshKey)}},
	)
}

// AddSystemdUnit appends contents in Ignition config
func (c *IgnConfig) AddSystemdUnit(name string, contents string, enabled bool) {
	unit := igntypes2.Unit{
		Name:     name,
		Contents: contents,
	}
	if enabled {
		unit.Enabled = util.BoolToPtr(true)
	}
	c.Systemd.Units = append(c.Systemd.Units, unit)
}

// AddSystemdDropins appends systemd dropins in the config
func (c *IgnConfig) AddSystemdDropins(name string, children []Dropin, enabled bool) {
	dropins := []igntypes2.SystemdDropin{}
	for _, childInfo := range children {

		dropins = append(dropins, igntypes2.SystemdDropin{
			Name:     childInfo.Name,
			Contents: childInfo.Contents,
		})
	}
	unit := igntypes2.Unit{
		Name:    name,
		Dropins: dropins,
	}
	if enabled {
		unit.Enabled = util.BoolToPtr(true)
	}
	c.Systemd.Units = append(c.Systemd.Units, unit)
}

// ReplaceOrAppend is a function which ensures duplicate files are not added in the file list
func ReplaceOrAppend(files []igntypes2.File, file igntypes2.File) []igntypes2.File {
	for i, f := range files {
		if f.Node.Path == file.Node.Path {
			files[i] = file
			return files
		}
	}
	files = append(files, file)
	return files
}
