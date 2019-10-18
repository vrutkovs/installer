module github.com/openshift/installer

go 1.13

require (
	cloud.google.com/go v0.45.1
	cloud.google.com/go/bigtable v1.0.0 // indirect
	contrib.go.opencensus.io/exporter/ocagent v0.4.11
	github.com/Azure/azure-sdk-for-go v29.0.0+incompatible
	github.com/Azure/go-autorest v12.1.0+incompatible
	github.com/BurntSushi/toml v0.3.1
	github.com/PuerkitoBio/purell v1.1.1
	github.com/PuerkitoBio/urlesc v0.0.0-20170810143723-de5bf2ad4578
	github.com/ajeddeloh/go-json v0.0.0-20170920214419-6a2fe990e083
	github.com/apparentlymart/go-cidr v1.0.1
	github.com/awalterschulze/gographviz v0.0.0-20170410065617-c84395e536e1
	github.com/aws/aws-sdk-go v1.25.3
	github.com/census-instrumentation/opencensus-proto v0.2.0
	github.com/containers/image v2.0.0+incompatible
	github.com/coreos/go-semver v0.2.0
	github.com/coreos/go-systemd v0.0.0-20181031085051-9002847aa142
	github.com/coreos/ignition v0.26.0
	github.com/davecgh/go-spew v1.1.1
	github.com/dgrijalva/jwt-go v3.2.0+incompatible
	github.com/dimchansky/utfbom v1.1.0
	github.com/dustinkirkland/golang-petname v0.0.0-20190613200456-11339a705ed2 // indirect
	github.com/emicklei/go-restful v2.10.0+incompatible
	github.com/ghodss/yaml v1.0.0
	github.com/go-openapi/jsonpointer v0.19.3
	github.com/go-openapi/jsonreference v0.19.3
	github.com/go-openapi/spec v0.19.3
	github.com/go-openapi/swag v0.19.5
	github.com/gogo/protobuf v1.2.0
	github.com/golang/glog v0.0.0-20160126235308-23def4e6c14b
	github.com/golang/mock v1.3.1
	github.com/golang/protobuf v1.3.2
	github.com/google/btree v1.0.0
	github.com/google/gofuzz v0.0.0-20170612174753-24818f796faf
	github.com/google/uuid v1.1.1
	github.com/googleapis/gnostic v0.2.0
	github.com/gophercloud/gophercloud v0.4.1-0.20190930034851-863d5406e68f
	github.com/gophercloud/utils v0.0.0-20190527093828-25f1b77b8c03
	github.com/gregjones/httpcache v0.0.0-20180305231024-9cad4c3443a7
	github.com/grpc-ecosystem/grpc-gateway v1.8.5
	github.com/hashicorp/golang-lru v0.5.1
	github.com/hashicorp/terraform v0.12.12 // indirect
	github.com/imdario/mergo v0.3.6
	github.com/inconshreveable/mousetrap v1.0.0
	github.com/jmespath/go-jmespath v0.0.0-20180206201540-c2b33e8439af
	github.com/json-iterator/go v1.1.5
	github.com/kballard/go-shellquote v0.0.0-20180428030007-95032a82bc51
	github.com/konsorten/go-windows-terminal-sequences v1.0.1
	github.com/kr/fs v0.1.0
	github.com/libvirt/libvirt-go v4.8.0+incompatible
	github.com/mailru/easyjson v0.7.0
	github.com/mattn/go-colorable v0.1.1
	github.com/mattn/go-isatty v0.0.5
	github.com/mgutz/ansi v0.0.0-20170206155736-9520e82c474b
	github.com/mitchellh/go-homedir v1.1.0
	github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd
	github.com/modern-go/reflect2 v1.0.1
	github.com/opencontainers/go-digest v1.0.0-rc1
	github.com/opencontainers/image-spec v1.0.1
	github.com/openshift/api v3.9.1-0.20190806225813-d2972510af76+incompatible
	github.com/openshift/client-go v0.0.0-20190806162413-e9678e3b850d
	github.com/openshift/cloud-credential-operator v0.0.0-20190905120421-44ed18ef8496
	github.com/openshift/cluster-api v0.0.0-20190619113136-046d74a3bd91
	github.com/openshift/cluster-api-provider-baremetal v0.0.0-20190702211226-53df0c29f8e2
	github.com/openshift/cluster-api-provider-gcp v0.0.1-0.20190826205919-0cd5daa07e0d
	github.com/openshift/cluster-api-provider-libvirt v0.2.1-0.20190613141010-ecea5317a4ab
	github.com/openshift/library-go v0.0.0-20190129125304-4b9f6ceb6598
	github.com/openshift/machine-config-operator v3.11.0+incompatible
	github.com/pborman/uuid v0.0.0-20180906182336-adf5a7427709
	github.com/petar/GoLLRB v0.0.0-20130427215148-53be0d36a84c
	github.com/peterbourgon/diskv v2.0.1+incompatible
	github.com/pkg/errors v0.8.1
	github.com/pkg/sftp v1.10.0
	github.com/pmezard/go-difflib v1.0.0
	github.com/shurcooL/httpfs v0.0.0-20171119174359-809beceb2371
	github.com/shurcooL/vfsgen v0.0.0-20181020040650-a97a25d856ca
	github.com/sirupsen/logrus v1.2.0
	github.com/spf13/cobra v0.0.3
	github.com/spf13/pflag v1.0.3
	github.com/stoewer/go-strcase v1.0.2 // indirect
	github.com/stretchr/testify v1.3.0
	github.com/terraform-providers/terraform-provider-aws v1.60.0 // indirect
	github.com/terraform-providers/terraform-provider-google v1.20.0 // indirect
	github.com/terraform-providers/terraform-provider-random v2.0.0+incompatible // indirect
	github.com/vincent-petithory/dataurl v0.0.0-20160330182126-9a301d65acbb
	go.opencensus.io v0.22.0
	go4.org v0.0.0-20180809161055-417644f6feb5
	golang.org/x/crypto v0.0.0-20190701094942-4def268fd1a4
	golang.org/x/net v0.0.0-20191009170851-d66e71096ffb
	golang.org/x/oauth2 v0.0.0-20190604053449-0f29369cfe45
	golang.org/x/sync v0.0.0-20190423024810-112230192c58
	golang.org/x/sys v0.0.0-20190804053845-51ab0e2deafa
	golang.org/x/text v0.3.2
	golang.org/x/time v0.0.0-20190308202827-9d24e82272b4
	google.golang.org/api v0.9.0
	google.golang.org/appengine v1.6.1
	google.golang.org/genproto v0.0.0-20190819201941-24fa4b261c55
	google.golang.org/grpc v1.21.1
	gopkg.in/AlecAivazis/survey.v1 v1.8.7
	gopkg.in/inf.v0 v0.9.1
	gopkg.in/ini.v1 v1.42.0
	gopkg.in/yaml.v2 v2.2.2
	k8s.io/api v0.0.0-20190409021203-6e4e0e4f393b
	k8s.io/apimachinery v0.0.0-20190404173353-6a84e37a896d
	k8s.io/client-go v11.0.1-0.20190409021438-1a26190bd76a+incompatible
	k8s.io/klog v0.3.0
	k8s.io/kube-openapi v0.0.0-20190918143330-0270cf2f1c1d
	k8s.io/utils v0.0.0-20190506122338-8fab8cb257d5
	sigs.k8s.io/controller-runtime v0.2.0-beta.2
	sigs.k8s.io/yaml v1.1.0
)

replace (
	github.com/metal3-io/baremetal-operator => github.com/openshift/baremetal-operator v0.0.0-20191001171423-cd2cdd14084a
	sigs.k8s.io/cluster-api-provider-aws => github.com/openshift/cluster-api-provider-aws v0.2.1-0.20190619152724-cf06d47b6cee
	sigs.k8s.io/cluster-api-provider-azure => github.com/openshift/cluster-api-provider-azure v0.1.0-alpha.3.0.20190718103506-6a50a8c59d8a
	sigs.k8s.io/cluster-api-provider-openstack => github.com/openshift/cluster-api-provider-openstack v0.0.0-20190925224209-945cf044115f
)
