require "ruboty/github"
require "active_support"
require "active_support/core_ext/string"
require "erb"

module Ruboty::Github::Actions
  class ReleasePR < Base
    USAGE = <<~EOS
    EOS

    def call
      create_release_pr if valid?
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
    rescue Octokit::Unauthorized
      message.reply("Failed in authentication (401)")
    rescue Octokit::NotFound => ex
      message.reply("Not Found (404): #{ex.message}")
    rescue => ex
      message.reply("Failed by #{ex.class}")
    end

    def valid?
      case
      when !has_access_token?
        require_access_token
        false
      when from_branch.blank?
        require_branch
        false
      when from_username.blank?
        require_username
        false
      when repository.blank?
        require_repository
        false
      when base.blank?
        require_base
        false
      else
        true
      end
    end

    def from_branch
      message[:from].split(":", -1).last.presence || ENV["GITHUB_RELEASE_PR_HEAD"]
    end

    def require_branch
      message.reply("Head branch is empty. Set ENV['GITHUB_RELEASE_PR_HEAD'] or specify <from>.")
    end

    def from_username
      message[:from].split(":", -1).first.presence || ENV["GITHUB_RELEASE_PR_USERNAME"]
    end

    def require_username
      message.reply("Username is empty. Set ENV['GITHUB_RELEASE_PR_USERNAME'] or specify <from>.")
    end

    def repository
      message[:to].split(":", -1).first.presence || ENV["GITHUB_RELEASE_PR_REPOSITORY"]
    end

    def require_repository
      message.reply("Repository name is empty. Set ENV['GITHUB_RELEASE_PR_REPOSITORY'] or specify <to>.")
    end

    def base
      message[:to].split(":", -1).last.presence || ENV["GITHUB_RELEASE_PR_BASE"]
    end

    def require_base
      message.reply("Base branch is empty. Set ENV['GITHUB_RELEASE_PR_BASE'] or specify <to>.")
    end

    def head
      "#{from_username}:#{from_branch}"
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
      @merged_pull_requests ||= compared_commits.each_with_object([]) do |log, pulls|
        next unless %r{\AMerge pull request #(?<pr_num>\d+)} =~ log.commit.message
        # NOTE: The response is https://developer.github.com/v3/pulls/#get-a-single-pull-request
        pulls << client.pull_request(repository, pr_num)
      end
    end

    DEFAULT_TITLE_FORMAT = "Release %Y-%m-%d %H:%M:%S.%L %z"
    private_constant :DEFAULT_TITLE_FORMAT

    DEFAULT_BODY_FORMAT = <<~EOS
      <% merged_pull_requests.each do |pr| %>
        - [ ] #<%= pr.number %> <%= pr.title %> @<%= user.login %>
      <% end %>
    EOS
    private_constant :DEFAULT_BODY_FORMAT
  end
end
