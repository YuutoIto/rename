#main-routineを実行しないようにする
DO_SPEC = true
require "../src/rbrn.rb"
require "fileutils"

include RenameUtils
TDIR = "tdir/"

describe "Rename spec" do
  before(:all) do
    FileUtils.rm_r(TDIR) if File.exist?(TDIR)
    FileUtils.mkdir(TDIR)
    Dir.chdir(TDIR)
  end
  after(:all) do
    Dir.chdir("../")
    FileUtils.rm_r(TDIR) if File.exist?(TDIR)
  end

  let(:files) { Dir.glob("*") }
  let(:count) { files.size }

  describe :safe_rename_pairs! do# {{{
    before(:all) { FileUtils.touch(%w[tmp.c out.c safe.c good.c]) }
    after(:all)  { FileUtils.remove(Dir.glob("*")) }

    subject { safe_rename_pairs!(pairs) }

    context "if names is duplicate" do
      let(:pairs) { [["tmp.c", "out.c"], ["safe.c", "good.c"]] }

      it "it is failure" do
        is_expected.to be_nil
        expect(count).to eq 4
        result = pairs.all? {|old, new| FileTest.exist?(old) && FileTest.exist?(new) }
        expect(result).to be_truthy
      end
    end

    context "if names is not duplicate" do
      let(:pairs) { [["tmp.c", "new1.c"], ["safe.c", "new2.c"]] }
      it "return is empty" do
        is_expected.to be_empty
        expect(count).to eq 4
      end

      it "rename successfully" do
        result = pairs.all? {|old, new| !FileTest.exist?(old) && FileTest.exist?(new) }
        expect(result).to be_truthy
      end
    end
  end# }}}

  describe :recursive_rename! do
    names =  %w[00.c 01.c 02.c 03.c 04.c 05.c]
    before(:each) { FileUtils.touch(names) }
    after(:each)  { FileUtils.remove(Dir.glob("*")) }
    subject { recursive_rename!(pairs) }

    #重複せずきれいに終わるパターン
    context "names is not duplicate" do
      let(:pairs) { [["00.c", "10.c"], ["01.c", "11.c"]] }
      it "it is successfully" do
        is_expected.to be_truthy
        expect(count).to eq names.size
      end
    end

    context "names is duplicate" do
      #重複して解決しないパターン
      context "it is missing" do
        let(:pairs) { [["00.c", "01.c"], ["02.c", "01.c"]] }
        it {
          old_out = $stdout.clone
          old_err = $stderr.clone
          $stdout = File.open("/dev/null", "w")
          $stderr = File.open("/dev/null", "w")
          is_expected.to be_falsey
          expect(count).to eq names.size
          $stdout = old_out
          $stderr = old_err
        }
      end

      #重複するが再帰で解決するパターン
      context "but it is successfully " do
        let(:pairs) { [["00.c", "01.c"], ["01.c", "21.c"]] }
        it {
          is_expected.to be_truthy
          expect(count).to eq names.size
        }
      end
    end
  end
end
