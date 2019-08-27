module github.com/openshift/installer/pkg/terraform/exec/plugins

go 1.12

require (
	cloud.google.com/go v0.40.0 // indirect
	contrib.go.opencensus.io/exporter/ocagent v0.4.12 // indirect
	github.com/Azure/go-autorest v11.9.0+incompatible // indirect
	github.com/Unknwon/com v0.0.0-20181010210213-41959bdd855f // indirect
	github.com/coreos/go-systemd v0.0.0-20190321100706-95778dfbb74e // indirect
	github.com/dimchansky/utfbom v1.1.0 // indirect
	github.com/dmacvicar/terraform-provider-libvirt v0.5.2
	github.com/gammazero/workerpool v0.0.0-20190608213748-0ed5e40ec55e // indirect
	github.com/gogo/protobuf v1.2.1 // indirect
	github.com/google/btree v1.0.0 // indirect
	github.com/gophercloud/gophercloud v0.0.0-20190509032623-7892efa714f1 // indirect
	github.com/gophercloud/utils v0.0.0-20190313033024-0bcc8e728cb5 // indirect
	github.com/hashicorp/terraform v0.12.0
	github.com/libvirt/libvirt-go-xml v5.1.0+incompatible // indirect
	github.com/mitchellh/packer v1.3.5 // indirect
	github.com/openshift-metal3/terraform-provider-ironic v0.1.7
	github.com/prometheus/client_golang v0.9.3-0.20190127221311-3c4408c8b829 // indirect
	github.com/satori/uuid v1.2.0 // indirect
	github.com/smartystreets/assertions v0.0.0-20190116191733-b6c0e53d7304 // indirect
	github.com/spf13/afero v1.2.2 // indirect
	github.com/terraform-providers/terraform-provider-aws v0.0.0-20190510001811-4b894dbf13f6
	github.com/terraform-providers/terraform-provider-azurerm v1.27.1
	github.com/terraform-providers/terraform-provider-google v0.0.0-20190604190225-5550fc28ca27
	github.com/terraform-providers/terraform-provider-ignition v1.0.1
	github.com/terraform-providers/terraform-provider-local v1.2.1
	github.com/terraform-providers/terraform-provider-openstack v1.15.1
	github.com/terraform-providers/terraform-provider-random v2.0.0+incompatible
	google.golang.org/appengine v1.6.1 // indirect
	k8s.io/apimachinery v0.0.0-20190313205120-d7deff9243b1 // indirect
	k8s.io/client-go v11.0.0+incompatible // indirect
	k8s.io/klog v0.3.0 // indirect
)

replace (
	github.com/Unknwon/com v0.0.0-20190804042917-757f69c95f3e => github.com/unknwon/com v0.0.0-20190804042917-757f69c95f3e
	github.com/mitchellh/packer => github.com/hashicorp/packer v1.3.5
	github.com/terraform-providers/terraform-provider-ignition => github.com/vrutkovs/terraform-provider-ignition v1.0.2-0.20190819094334-ac54201ee306
)
