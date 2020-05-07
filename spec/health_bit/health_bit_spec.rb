RSpec.describe HealthBit do
  subject do
    described_class.clone
  end

  describe '#configure' do
    let(:configure) do
      this = nil
      subject.configure { |o| this = o }
      this
    end

    it 'yields self' do
      expect(configure).to eq(subject)
    end
  end

  describe '#success_code, #success_code=' do
    context 'when default' do
      it 'works' do
        expect(subject.success_code).to eq(200)
      end
    end

    context 'when set' do
      before do
        subject.success_code = 0
      end

      it 'works' do
        expect(subject.success_code).to eq(0)
      end
    end
  end

  describe '#fail_code, #fail_code=' do
    context 'when default' do
      it 'works' do
        expect(subject.fail_code).to eq(500)
      end
    end

    context 'when set' do
      before do
        subject.fail_code = 0
      end

      it 'works' do
        expect(subject.fail_code).to eq(0)
      end
    end
  end

  describe '#headers, #headers=' do
    context 'when default' do
      it 'works' do
        expect(subject.headers).to eq({'Content-Type' => 'text/plain', 'Cache-Control' => 'private,max-age=0,must-revalidate,no-store' })
      end
    end

    context 'when set' do
      before do
        subject.headers = { foo: :bar }
      end

      it 'works' do
        expect(subject.headers).to eq(foo: :bar)
      end
    end
  end

  describe '#success_text, #success_text=' do
    context 'when default' do
      it 'works' do
        expect(subject.success_text).to eq('0 checks passed 🎉')
      end
    end

    context 'when set' do
      before do
        subject.success_text = 'foo'
      end

      it 'works' do
        expect(subject.success_text).to eq('foo')
      end
    end
  end

  describe '#add' do
    it 'returns self' do
      expect(subject.add('1', Class.new)).to eq(subject)
    end

    context 'when object' do
      before do
        subject.add('foo', Class.new)
      end

      it 'add check' do
        expect(subject.checks.length).to eq(1)
        expect(subject.checks.first).to have_attributes(name: 'foo')
      end
    end

    context 'when block' do
      before do
        subject.add('bar') do
          1
        end
      end

      it 'works' do
        expect(subject.checks.length).to eq(1)
        expect(subject.checks.first).to have_attributes(name: 'bar')
      end
    end

    context 'when both handler and block passed' do
      let(:add) do
        subject.add('bar', Class.new) do
          1
        end
      end

      it 'errors' do
        expect { add }.to raise_error(ArgumentError)
      end
    end

    context 'when nor handler or block passed' do
      let(:add) do
        subject.add('bar')
      end

      it 'errors' do
        expect { add }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#rack' do
    let(:response) do
      subject.rack.call({}).to_s
    end

    context 'when show_backtrace=true' do
      before do
        subject.show_backtrace = true
        subject.add('foo') { false }
      end

      it 'print backtrace' do
        expect(response).to include('health_bit/lib/health_bit')
      end
    end

    context 'when show_backtrace=false' do
      before do
        subject.add('foo') { false }
      end

      it 'hides backtrace' do
        expect(response).not_to include('health_bit/lib/health_bit')
      end
    end

    context 'when adding middleware' do
      it 'works' do
        expect { subject.rack.use(Class.new) }.to change { subject.rack.instance_variable_get(:@use).count }.by(1)
      end
    end
  end
end
