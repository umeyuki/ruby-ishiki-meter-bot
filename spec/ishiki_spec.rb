# -*- coding: utf-8 -*-
require 'ishiki'
require 'yaml'
describe Ishiki do
  before(:all) do
    @word_map = {}
    YAML.load_file('./data/words.yml').map do |w|
      @word_map[w['name']] = w['value']
    end
  end

  context "意識が高い" do
    it '意識レベル6 金持ち父さん貧乏父さん読了' do
      text = "金持ち父さん貧乏父さん読了"
      expect(Ishiki.level(text)).to eq 6
      expect(Ishiki.high_level?(text)).to be true
    end

    it '意識レベル5 ストレスフリーGTDのタスク術' do
      text = "ストレスフリーGTDのタスク術"
      expect(Ishiki.level(text)).to eq 5
      expect(Ishiki.high_level?(text)).to be true
    end
  end

  context "意識が高くない" do
    it '意識レベル4 アイデアをモレスキンノートに書き残した' do
      text = "アイデアをモレスキンノートに書き残した"
      expect(Ishiki.level(text)).to eq 4
      expect(Ishiki.high_level?(text)).to be false
    end

  end
  
end
