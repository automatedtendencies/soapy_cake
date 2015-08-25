RSpec.describe SoapyCake::AdminBatched do
  let(:admin) { double('admin') }

  before :each do
    allow(SoapyCake::Admin).to receive(:new).and_return(admin)

    stub_const('SoapyCake::AdminBatched::BatchedRequest::LIMIT', 2)
  end

  it 'returns an enumerator and uses batched CAKE calls' do
    expect(admin).to receive(:offers)
      .with(advertiser: 1, start_at_row: 1, row_limit: 2).and_return(%i(a b).to_enum)
    expect(admin).to receive(:offers)
      .with(advertiser: 1, start_at_row: 3, row_limit: 2).and_return(%i(c).to_enum)

    result = subject.offers(advertiser: 1)

    expect(result).to be_a(Enumerator)
    expect(result.to_a).to eq(%i(a b c))
  end

  it 'can use a custom limit' do
    expect(admin).to receive(:offers)
      .with(advertiser: 1, start_at_row: 1, row_limit: 100).and_return(%i(a b).to_enum)

    expect(subject.offers({ advertiser: 1 }, 100).to_a).to eq(%i(a b))
  end

  context 'errors' do
    it 'fails with an invalid method' do
      expect { subject.something }.to raise_error(/Invalid method something/)
    end

    it 'fails when row_limit is set' do
      expect { subject.offers(row_limit: 123) }.to raise_error(/Cannot set .* in batched mode/)
    end

    it 'fails when start_at_row is set' do
      expect { subject.offers(start_at_row: 123) }.to raise_error(/Cannot set .* in batched mode/)
    end
  end
end