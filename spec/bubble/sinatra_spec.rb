require "spec_helper"

class Number
  attr_accessor :value, :numberwang
  @@collection = []
  def self.truncate
    @@collection = []
  end
  def self.search(filter)
    results = @@collection.dup
    results.select!(&:odd?) if filter[:odd]=="1"
    results
  end
  def initialize(opts={})
    @value = opts[:value].to_i
    @numberwang = !!opts[:numberwang]
  end
  def odd?
    @value.odd?
  end
  def as_json(context)
    links = case context
    when :index
      [{rel: "self", href: url}]
    end
    {value: value, numberwang: numberwang, link: links}
  end
  def save
    @@collection << self
  end
  def url
    "http://example.org/number/#{value}"
  end
end
class Api < Sinatra::Base
  register Sinatra::Bubble
  resource :number
end

describe Sinatra::Bubble do
  include Rack::Test::Methods

  def app
    Api.new
  end

  context "Create" do
  end
  context "Index" do
    context "get /number without number" do
      before(:all){ get "/number" }
      it("code is 200") { last_response.status.should == 200 }
      it("content-type is application/json") { last_response.content_type.should == "application/json" }
      it "body contains link to self and no number" do
        hash = Yajl::Parser.parse last_response.body
        hash.should == {
          "number" => [],
          "link" => [
            {"rel" => "self", "href" => "http://example.org/number"}
          ],
        }
      end
    end
    context "get /number with numbers" do
      before :all do
        Number.new(:value => 1).save
        Number.new(:value => 2, :numberwang => true).save
        get "/number"
      end
      after(:all){ Number.truncate }
      it("code is 200") { last_response.status.should == 200 }
      it("content-type is application/json") { last_response.content_type.should == "application/json" }
      it "body contains link to self and numbers with a link to each" do
        hash = Yajl::Parser.parse last_response.body
        hash.should == {
          "number" => [
            {
              "value" => 1,
              "numberwang" => false,
              "link" => [
                {"rel" => "self", "href" => "http://example.org/number/1"}
              ],
            },
            {
              "value" => 2,
              "numberwang" => true,
              "link" => [
                {"rel" => "self", "href" => "http://example.org/number/2"}
              ],
            },
          ],
          "link" => [
            {"rel" => "self", "href" => "http://example.org/number"}
          ],
        }
      end
    end
  end
  context "Searches" do
  end
  context "Show" do
  end
  context "Destroy" do
  end
  context "Update" do
  end
  context "Conditional request" do
  end
  context "Resource not found" do
  end
  context "Errors on create" do
  end
  context "Invalid serialization" do
  end
end