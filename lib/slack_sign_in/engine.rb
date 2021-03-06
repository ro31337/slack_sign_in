require "oauth2"
require "slack_sign_in/test_client"

module SlackSignIn
  class Engine < ::Rails::Engine
    isolate_namespace SlackSignIn

    config.slack_sign_in = ActiveSupport::OrderedOptions.new

    initializer "slack_sign_in.config" do |app|
      config.after_initialize do
        SlackSignIn.client_id = config.slack_sign_in.client_id || app.credentials.dig(:slack_sign_in, :client_id)
        SlackSignIn.client_secret = config.slack_sign_in.client_secret || app.credentials.dig(:slack_sign_in, :client_secret)
        SlackSignIn.scopes = config.slack_sign_in.scopes || SlackSignIn::DEFAULT_SCOPES
        SlackSignIn.client = config.slack_sign_in.client || OAuth2::Client
      end
    end

    initializer "slack_sign_in.helpers" do
      ActiveSupport.on_load :action_controller_base do
        helper SlackSignIn::Engine.helpers
      end
    end

    initializer "slack_sign_in.mount" do |app|
      app.routes.prepend do
        mount SlackSignIn::Engine, at: app.config.slack_sign_in.root || "slack_sign_in"
      end
    end

    initializer "slack_sign_in.parameter_filters" do |app|
      app.config.filter_parameters << :code
    end
  end
end
