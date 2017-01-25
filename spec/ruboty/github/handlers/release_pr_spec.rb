RSpec.describe Ruboty::Handlers::ReleasePR do
  describe "#create_release_pr" do
    subject { Ruboty::Github::Actions::ReleasePR.new(message).call }

    around do |example|
      travel_to Time.new(2017, 1, 22, 11, 20, 0, "+09:00") do
        example.run
      end
    end

    # shared_examples 'title is `Release YYYY-mm-dd HH:MM:ss.LLL +z`' do
    #   it { subject }
    # end

    before do
      allow_any_instance_of(Ruboty::Github::Actions::Base)
        .to receive(:access_token).and_return(access_token)
    end

    let(:access_token) { "access_token" }
    let(:action) { Ruboty::Handlers::ReleasePR.actions.find { |action| action.name == "create_release_pr" } }

    shared_examples "failed to create PR with error message" do
      before { message.match(pattern) }

      let(:error_message) { fail NotImplementedError }

      it "replies error message" do
        expect(message).to receive(:reply).with(error_message)
        subject
      end

      it "sends no request" do
        expect(a_request(:post, //)).not_to have_been_made
        subject
      end
    end

    context 'when no given github access token' do
      let(:access_token) { '' }
      let(:message) { Ruboty::Message.new(body: "release from #{from} to #{to}") }
      let(:pattern) { action.pattern }
      let(:from) { "mgi166/repo:master" }
      let(:to) { "other/repo:feature" }

      it_behaves_like "failed to create PR with error message" do
        let(:error_message) { "" }
      end
    end

    # context 'when no base given' do
    #   let(:message) { {} }

    #   it 'description' do
    #   end
    # end

    context 'when no head given' do
    end
  end
end
