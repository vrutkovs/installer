// +build !okd

package ignition

import (
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"path/filepath"

	"github.com/coreos/ignition/config/util"
	igntypes2 "github.com/coreos/ignition/config/v2_4/types"
	"github.com/pkg/errors"

	mcfgv1 "github.com/openshift/machine-config-operator/pkg/apis/machineconfiguration.openshift.io/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	"github.com/openshift/installer/pkg/asset/openshiftinstall"

	"github.com/openshift/installer/pkg/asset"
	"github.com/vincent-petithory/dataurl"
)

// Config is ignition v2 Config
type Config igntypes2.Config

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
func PointerIgnitionConfig(url string, rootCA []byte) *Config {
	return &Config{
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
func GenerateMinimalConfig() *Config {
	return &Config{
		Ignition: igntypes2.Ignition{
			Version: igntypes2.MaxVersion.String(),
		},
	}
}

// AddSSHKey returns a minimal ignition v2 config
func (c *Config) AddSSHKey(sshKey, bootstrapSSHKeyPair string) {
	c.Passwd.Users = append(
		c.Passwd.Users,
		igntypes2.PasswdUser{Name: "core", SSHAuthorizedKeys: []igntypes2.SSHAuthorizedKey{igntypes2.SSHAuthorizedKey(sshKey), igntypes2.SSHAuthorizedKey(bootstrapSSHKeyPair)}},
	)
}

// AddSystemdUnit appends contents in Ignition config
func (c *Config) AddSystemdUnit(name string, contents string, enabled bool) {
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
func (c *Config) AddSystemdDropins(name string, children []Dropin, enabled bool) {
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
func (c *Config) ReplaceOrAppend(file igntypes2.File) {
	for i, f := range c.Storage.Files {
		if f.Node.Path == file.Node.Path {
			c.Storage.Files[i] = file
			return
		}
	}
	c.Storage.Files = append(c.Storage.Files, file)
}

// To allow Ignition to download its config on the bootstrap machine from a location secured by a
// self-signed certificate, we have to provide it a valid custom ca bundle.
// To do so we generate a small ignition config that contains just Security section with the bundle
// and later append it to the main ignition config.
// We can't do it directly in Terraform, because Ignition provider suppors only 2.1 version, but
// Security section was added in 2.2 only.

// GenerateIgnitionShim is used to generate an ignition file that contains a user ca bundle
// in its Security section.
func GenerateIgnitionShim(userCA string, clusterID string, bootstrapConfigURL string, tokenID string) (string, error) {
	fileMode := 420

	// Hostname Config
	contents := fmt.Sprintf("%s-bootstrap", clusterID)

	hostnameConfigFile := igntypes2.File{
		Node: igntypes2.Node{
			Filesystem: "root",
			Path:       "/etc/hostname",
		},
		FileEmbedded1: igntypes2.FileEmbedded1{
			Mode: &fileMode,
			Contents: igntypes2.FileContents{
				Source: dataurl.EncodeBytes([]byte(contents)),
			},
		},
	}

	// Openstack Ca Cert file
	openstackCAFile := igntypes2.File{
		Node: igntypes2.Node{
			Filesystem: "root",
			Path:       "/opt/openshift/tls/cloud-ca-cert.pem",
		},
		FileEmbedded1: igntypes2.FileEmbedded1{
			Mode: &fileMode,
			Contents: igntypes2.FileContents{
				Source: dataurl.EncodeBytes([]byte(userCA)),
			},
		},
	}

	security := igntypes2.Security{}
	if userCA != "" {
		carefs := []igntypes2.CaReference{}
		rest := []byte(userCA)

		for {
			var block *pem.Block
			block, rest = pem.Decode(rest)
			if block == nil {
				return "", fmt.Errorf("unable to parse certificate, please check the cacert section of clouds.yaml")
			}

			carefs = append(carefs, igntypes2.CaReference{Source: dataurl.EncodeBytes(pem.EncodeToMemory(block))})

			if len(rest) == 0 {
				break
			}
		}

		security = igntypes2.Security{
			TLS: igntypes2.TLS{
				CertificateAuthorities: carefs,
			},
		}
	}

	headers := []igntypes2.HTTPHeader{
		{
			Name:  "X-Auth-Token",
			Value: tokenID,
		},
	}

	ign := igntypes2.Config{
		Ignition: igntypes2.Ignition{
			Version:  igntypes2.MaxVersion.String(),
			Security: security,
			Config: igntypes2.IgnitionConfig{
				Append: []igntypes2.ConfigReference{
					{
						Source:      bootstrapConfigURL,
						HTTPHeaders: headers,
					},
				},
			},
		},
		Storage: igntypes2.Storage{
			Files: []igntypes2.File{
				hostnameConfigFile,
				openstackCAFile,
			},
		},
	}

	data, err := json.Marshal(ign)
	if err != nil {
		return "", err
	}

	// Check the size of the base64-rendered ignition shim isn't to big for nova
	// https://docs.openstack.org/nova/latest/user/metadata.html#user-data
	if len(base64.StdEncoding.EncodeToString(data)) > 65535 {
		return "", fmt.Errorf("rendered bootstrap ignition shim exceeds the 64KB limit for nova user data -- try reducing the size of your CA cert bundle")
	}

	return string(data), nil
}
