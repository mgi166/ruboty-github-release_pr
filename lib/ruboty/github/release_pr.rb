require 'ruboty/github'
require 'ruboty/github/release_pr/version'
require 'ruboty/github/handlers/release_pr'
require 'ruboty/github/actions/release_pr'

module Ruboty::Github::ReleasePR
  # NOTE: response is https://developer.github.com/v3/pulls/#get-a-single-pull-request
  #
  class PullRequest
    extend Forwardable

    def initialize(response)
      @response = response
    end

    def_delegators :@response,
                   :id,
                   :url,
                   :number,
                   :title,
                   :body,
                   :state,
                   :locked,
                   :user,
                   :body,
                   :html_url,
                   :diff_url,
                   :patch_url,
                   :issue_url,
                   :created_at,
                   :updated_at,
                   :merged_at,
                   :closed_at,
                   :assignee,
                   :assignees,
                   :milestone
  end
end
