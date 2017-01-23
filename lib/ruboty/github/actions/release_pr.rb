require "ruboty/github"
require "erb"

module Ruboty::Github::Actions
  class ReleasePR < Base
    def call
      has_access_token? ? create_release_pr : require_access_token
    end

    private

    def create_release_pr
      client.create_pull_request(
        repository,
        base,
        head,
        title,
        body
      )
    end

    def from
      message[:from]
    end

    def from_branch
      from.split(":").last
    end

    def from_user
      from.split(":").first
    end

    def to
      message[:to]
    end

    def repository
      to.split(":").first
    end

    def base
      to.split(":").last
    end

    def head
      "#{from_user}:#{from_branch}"
    end

    def title
      now = Time.now
      ENV["GITHUB_RELEASE_PR_TITLE_FORMAT"] ? now.stftime(ENV["GITHUB_RELEASE_PR_TITLE_FORMAT"]) : now.strftime(DEFAULT_TITLE_FORMAT)
    end

    def body
      template = ENV["GITHUB_RELEASE_PR_BODY_FORMAT"] ? ENV["GITHUB_RELEASE_PR_BODY_FORMAT"] : DEFAULT_BODY_FORMAT
      ERB.new(template).result(binding)
    end

    def compared_commits
      client.compare(repository, base, head)
    end

    def merged_pull_requests
      @merged_pull_requests ||= compared_commits.each_with_object([]) do |x, pulls|
        next unless %r{\AMerge pull request #(?<pr_num>\d+)} =~ x.commit.message
        # NOTE: The response is https://developer.github.com/v3/pulls/#get-a-single-pull-request
        pulls << client.pull_request(repository, pr_num)
      end
    end

    DEFAULT_TITLE_FORMAT = "Release %Y-%m-%d %H:%M:%S.%L %z"
    private_constant :DEFAULT_TITLE_FORMAT

    DEFAULT_BODY_FORMAT = <<~EOS
      <%= merged_pull_requests.each do |pr| %>
        - [ ] #<%= pr.number %> <%= pr.title %> @<%= user.login %>
      <% end %>
    EOS
    private_constant :DEFAULT_BODY_FORMAT
  end
end
