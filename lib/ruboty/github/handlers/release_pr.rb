module Ruboty::Handlers
  class ReleasePR < Base
    on(
      /release from (?<from>.+) to (?<to>.+)\z/i,
      name: "create_release_pr",
      description: "Create release PR"
    )

    def create_release_pr(message)
      Ruboty::Github::Actions::ReleasePR.new(message).call
    end
  end
end
