require_relative '../plugin_helper'

describe LandingPages::Importer do
  let(:raw_global) {
    JSON.parse(File.open(
      "#{Rails.root}/plugins/discourse-landing-pages/spec/fixtures/pages.json"
    ).read)
  }
  let(:raw_assets) {
    JSON.parse(File.open(
      "#{Rails.root}/plugins/discourse-landing-pages/spec/fixtures/assets.json"
    ).read)
  }
  let(:raw_page) {
    JSON.parse(File.open(
      "#{Rails.root}/plugins/discourse-landing-pages/spec/fixtures/page.json"
    ).read)
  }
  let(:raw_body) {
    File.open(
      "#{Rails.root}/plugins/discourse-landing-pages/spec/fixtures/body.html.erb"
    ).read
  }
  
  before do
    temp_folder_path = "#{Rails.root}/plugins/discourse-landing-pages/spec/fixtures"
    temp_folder = Pathname.new(temp_folder_path).realpath.to_s

    LandingPages::Importer.any_instance.stubs(:temp_folder).returns(temp_folder)
    LandingPages::GitImporter.any_instance.stubs(:import!).returns(true)
    LandingPages::GitImporter.any_instance.stubs(:connected).returns(true)
    LandingPages::GitImporter.any_instance.stubs(:version).returns("69acc9abf1026c038ae99a0c91f4e15afa454333")
    LandingPages::GitImporter.any_instance.stubs(:cleanup!).returns(true)
  end
  
  it "performs an import" do
    importer = LandingPages::Importer.new(:git)
    importer.perform!
    
    global = LandingPages::Global.find
    expect(global.scripts).to eq(raw_global['scripts'])
    expect(global.footer).to eq(raw_global['footer'])
    expect(global.header).to eq(raw_global['header'])
    
    assets = LandingPages::Asset.all
    expect(assets.length).to eq(2)
    
    page = LandingPages::Page.all
    expect(page.length).to eq(2)
  end
  
  it "generates an import report" do
    importer = LandingPages::Importer.new(:git)
    importer.perform!
    
    expect(importer.report).to eq(
      {
        imported: {
          scripts: true,
          footer: true,
          header: true,
          menus: ["my_menu"],
          assets: ["asset_1", "asset_2"],
          pages: ["My Second Page", "My Page"]
        },
        errors: []
      }
    )
  end
end