module github.com/openshift/installer

go 1.12

require (
	cloud.google.com/go v0.41.0 // indirect
	github.com/Azure/azure-sdk-for-go v32.5.0+incompatible
	github.com/Azure/go-ansiterm v0.0.0-20170929234023-d6e3b3328b78 // indirect
	github.com/Azure/go-autorest/autorest v0.9.0
	github.com/Azure/go-autorest/autorest/azure/auth v0.3.0
	github.com/Azure/go-autorest/autorest/to v0.3.0
	github.com/MakeNowJust/heredoc v1.0.0 // indirect
	github.com/Netflix/go-expect v0.0.0-20190729225929-0e00d9168667
	github.com/Sirupsen/logrus v1.4.0 // indirect
	github.com/apparentlymart/go-cidr v1.0.0
	github.com/awalterschulze/gographviz v0.0.0-20170410065617-c84395e536e1
	github.com/aws/aws-sdk-go v1.22.0
	github.com/containers/image v2.0.0+incompatible
	github.com/coreos/ignition v0.33.0
	github.com/coreos/ignition/v2 v2.0.1
	github.com/dmacvicar/terraform-provider-libvirt v0.5.2
	github.com/docker/docker v1.13.1 // indirect
	github.com/dustinkirkland/golang-petname v0.0.0-20190613200456-11339a705ed2 // indirect
	github.com/exponent-io/jsonpath v0.0.0-20151013193312-d6023ce2651d // indirect
	github.com/ghodss/yaml v1.0.0
	github.com/go-logr/zapr v0.1.0 // indirect
	github.com/golang/mock v1.3.1
	github.com/gophercloud/gophercloud v0.3.1-0.20190807175045-25a84d593c97
	github.com/gophercloud/utils v0.0.0-20190527093828-25f1b77b8c03
	github.com/gregjones/httpcache v0.0.0-20190611155906-901d90724c79 // indirect
	github.com/hashicorp/go-plugin v1.0.1
	github.com/hashicorp/logutils v1.0.0
	github.com/hashicorp/terraform v0.12.7
	github.com/hinshun/vt10x v0.0.0-20180809195222-d55458df857c
	github.com/kballard/go-shellquote v0.0.0-20180428030007-95032a82bc51 // indirect
	github.com/kr/fs v0.1.0 // indirect
	github.com/libvirt/libvirt-go v5.0.0+incompatible
	github.com/metal3-io/baremetal-operator v0.0.0-20190822124022-58c455095b51
	github.com/metal3-io/cluster-api-provider-baremetal v0.0.0-20190823184140-acab6c77caaa
	github.com/mgutz/ansi v0.0.0-20170206155736-9520e82c474b // indirect
	github.com/mitchellh/cli v1.0.0
	github.com/onsi/ginkgo v1.8.0
	github.com/onsi/gomega v1.5.0
	github.com/openshift-metal3/terraform-provider-ironic v0.1.7
	github.com/openshift/api v0.0.0-20190806225813-d2972510af76
	github.com/openshift/client-go v0.0.0-20190806162413-e9678e3b850d
	github.com/openshift/cloud-credential-operator v0.0.0-20190619194303-c89dc7733001
	github.com/openshift/cluster-api v0.0.0-20190619113136-046d74a3bd91
	github.com/openshift/cluster-api-provider-gcp v0.0.0-20190801154446-f5146705932b
	github.com/openshift/cluster-api-provider-libvirt v0.0.0-20190613141010-ecea5317a4ab
	github.com/openshift/library-go v0.0.0-20190704075327-f8abdcd57c46
	github.com/openshift/machine-config-operator v0.0.0-00010101000000-000000000000
	github.com/pborman/uuid v1.2.0
	github.com/peterbourgon/diskv v2.0.1+incompatible // indirect
	github.com/pkg/errors v0.8.1
	github.com/pkg/sftp v1.10.0
	github.com/prometheus/client_golang v1.1.0 // indirect
	github.com/prometheus/client_model v0.0.0-20190812154241-14fe0d1b01d4 // indirect
	github.com/russross/blackfriday v2.0.0+incompatible // indirect
	github.com/shurcooL/sanitized_anchor_name v1.0.0 // indirect
	github.com/sirupsen/logrus v1.4.2
	github.com/spf13/cobra v0.0.5
	github.com/stoewer/go-strcase v1.0.2 // indirect
	github.com/stretchr/testify v1.3.0
	github.com/terraform-providers/terraform-provider-aws v1.60.0
	github.com/terraform-providers/terraform-provider-azurerm v1.33.0
	github.com/terraform-providers/terraform-provider-google v1.20.0
	github.com/terraform-providers/terraform-provider-ignition v1.1.0
	github.com/terraform-providers/terraform-provider-local v1.3.0
	github.com/terraform-providers/terraform-provider-openstack v1.21.1
	github.com/terraform-providers/terraform-provider-random v2.0.0+incompatible
	github.com/ugorji/go v1.1.7 // indirect
	github.com/vincent-petithory/dataurl v0.0.0-20160330182126-9a301d65acbb
	golang.org/x/crypto v0.0.0-20190701094942-4def268fd1a4
	golang.org/x/oauth2 v0.0.0-20190604053449-0f29369cfe45
	golang.org/x/sys v0.0.0-20190801041406-cbf593c0f2f3
	google.golang.org/api v0.7.0
	gopkg.in/AlecAivazis/survey.v1 v1.8.1
	gopkg.in/airbrake/gobrake.v2 v2.0.9 // indirect
	gopkg.in/gemnasium/logrus-airbrake-hook.v2 v2.1.2 // indirect
	gopkg.in/ini.v1 v1.42.0
	gopkg.in/yaml.v2 v2.2.2
	k8s.io/api v0.0.0-20190826194732-9f642ccb7a30
	k8s.io/apimachinery v0.0.0-20190826114657-e31a5531b558
	k8s.io/cli-runtime v0.0.0-20190823123533-5ef25e8d2ab0 // indirect
	k8s.io/client-go v11.0.1-0.20190409021438-1a26190bd76a+incompatible
	k8s.io/kubernetes v1.14.6
	k8s.io/utils v0.0.0-20190801114015-581e00157fb1
	sigs.k8s.io/cluster-api-provider-aws v0.0.0-20190826194037-47eff4512368
	sigs.k8s.io/cluster-api-provider-azure v0.0.0-20190820233118-7bf6590e249c
	sigs.k8s.io/cluster-api-provider-openstack v0.0.0-20190826064620-dcd9c3c09451
	sigs.k8s.io/controller-runtime v0.2.0-alpha.0 // indirect
	sigs.k8s.io/testing_frameworks v0.1.1 // indirect
)

replace (
	github.com/Sirupsen/logrus v1.0.5 => github.com/sirupsen/logrus v1.0.5
	github.com/Sirupsen/logrus v1.3.0 => github.com/Sirupsen/logrus v1.0.6
	github.com/Sirupsen/logrus v1.4.0 => github.com/sirupsen/logrus v1.0.6
	github.com/metal3-io/baremetal-operator => github.com/openshift/baremetal-operator v0.0.0-20190715205730-7fa47751bf92
	github.com/metal3-io/cluster-api-provider-baremetal => github.com/openshift/cluster-api-provider-baremetal v0.0.0-20190702211226-53df0c29f8e2
	github.com/openshift/machine-config-operator => github.com/vrutkovs/machine-config-operator v0.0.0-20190827140812-8f650ef3b35b
	sigs.k8s.io/cluster-api-provider-aws => github.com/openshift/cluster-api-provider-aws v0.2.1-0.20190619152724-cf06d47b6cee
	sigs.k8s.io/cluster-api-provider-azure => github.com/openshift/cluster-api-provider-azure v0.1.0-alpha.3.0.20190718103506-6a50a8c59d8a
	sigs.k8s.io/cluster-api-provider-openstack => github.com/openshift/cluster-api-provider-openstack v0.0.0-20190805125606-076f2c35a030
)
