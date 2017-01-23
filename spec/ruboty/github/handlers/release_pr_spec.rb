RSpec.describe Ruboty::Handlers::ReleasePR do
  describe "#create_release_pr" do
    subject { Ruboty::Handlers::ReleasePR.new.call }

    around do |example|
      travel_to Time.new(2017, 1, 22, 11, 20, 0, "+09:00") do
        example.run
      end
    end

    before do
      stub_request(:post, "https://api.github.com/repos/mgi166/dummy-repo/pulls")
        .with(
          title: title,
          body: body,
          head: head,
          base: base
        )
    end

    shared_exampes 'title is `Release YYYY-mm-dd HH:MM:ss.LLL +z`' do
      let(:title) { "Release 2017-01-22 11:20:00.000 +0900" }

      it { subject }
    end

    context 'when no base given' do
    end

    context 'when no head given' do
    end
  end
end
