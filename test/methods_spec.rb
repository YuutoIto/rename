require "../src/utils.rb"
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
    # FileUtils.rm_r(TDIR) if File.exist?(TDIR)
  end

  let(:count) { Dir.glob("*").size }

  describe :safe_rename_pairs! do# {{{
    before(:all) { FileUtils.touch(%w[tmp.c out.c safe.c good.c]) }
    after(:all)  { FileUtils.remove(Dir.glob("*")) }

    subject { safe_rename_pairs!(pairs) }

    context "if names is duplicate" do
      let(:pairs) { [["tmp.c", "out.c"], ["safe.c", "good.c"]] }

      it "return is not empty" do
        expect(Dir.glob("*").size).to eq 4
        is_expected.to be_nil
        expect(Dir.glob("*").size).to eq 4
      end

      it "rename failure" do
        result = pairs.all? {|old, new| FileTest.exist?(old) && FileTest.exist?(new) }
        expect(result).to be_truthy
      end
    end

    context "if names is not duplicate" do
      let(:pairs) { [["tmp.c", "new1.c"], ["safe.c", "new2.c"]] }
      it "return is empty" do
        expect(Dir.glob("*").size).to eq 4
        is_expected.to be_empty
        expect(Dir.glob("*").size).to eq 4
      end

      it "rename successfully" do
        result = pairs.all? {|old, new| !FileTest.exist?(old) && FileTest.exist?(new) }
        expect(result).to be_truthy
      end
    end
  end# }}}

  describe :recursive_rename! do
    names =  %w[00.c 01.c 02.c 03.c 04.c 05.c]
    before(:all) { FileUtils.touch(names) }
    after(:all)  { FileUtils.remove(Dir.glob("*")) }
    subject { recursive_rename!(pairs) }

    #重複せずきれいに終わるパターン
    context "names is not duplicate" do
      let(:pairs) { [["00.c", "10.c"], ["01.c", "11.c"]] }
      it "it is successfully" do
        is_expected.to be_truthy
      end

      it "not changed file num" do
        expect(Dir.glob("*").size).to eq names.size
      end
    end

    context "names is duplicate" do
      #重複して解決しないパターン
      context "it is missing" do
        let(:pairs) { [["00.c", "01.c"], ["02.c", "01.c"]] }
        it { is_expected.to be_falsey }
        it { expect(Dir.glob("*").size).to eq names.size }
      end

      #重複するが再帰で解決するパターン
      context "but it is successfully " do
        let(:pairs) { [["00.c", "01.c"], ["01.c", "21.c"]] }
        it { is_expected.to be_falsey }
        it { expect(Dir.glob("*").size).to eq names.size }
      end
    end


  end
end
