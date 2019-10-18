package plugins

import (
	"github.com/hashicorp/terraform/plugin"
	"github.com/terraform-providers/terraform-provider-aws/v2/aws"
)

func init() {
	exec := func() {
		plugin.Serve(&plugin.ServeOpts{
			ProviderFunc: aws.Provider,
		})
	}
	KnownPlugins["terraform-provider-aws"] = exec
}
