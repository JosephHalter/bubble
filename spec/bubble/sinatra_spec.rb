require "spec_helper"

class Number
  attr_accessor :value, :numberwang, :errors
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
    @value = opts["value"].to_i if opts["value"]
    @numberwang = !!opts["numberwang"]
    @errors = []
  end
  def odd?
    @value.odd?
  end
  def as_json(context)
    case context
    when :show
      {
        urn: urn,
        value: value,
        numberwang: numberwang,
        link: [
          {rel: "self", href: url},
          {rel: "number", href: "#{Api.base_url}/number"},
        ],
      }
    when :new
      {value: value, numberwang: numberwang, errors: errors}
    when :index
      {
        urn: urn,
        value: value,
        numberwang: numberwang,
        link: [
          {rel: "self", href: url},
        ],
      }
    end
  end
  def valid?
    @errors = {}
    @errors[:value] = ["can't be blank"] unless @value
    @errors.empty?
  end
  def save
    valid? && @@collection << self
  end
  def urn
    "urn:api:number:#{value}"
  end
  def url
    "#{Api.base_url}/number/#{value}"
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
    context "without error" do
      before :all do
        Number.truncate
        post "/number", '{"value": 3}'
      end
      it("status is 201 Created") { last_response.status.should == 201 }
      it("content-type is application/json") { last_response.content_type.should == "application/json;charset=utf-8" }
      it "body includes urn, link to self and link to collection" do
        hash = Yajl::Parser.parse last_response.body
        hash.should == {
          "urn" => "urn:api:number:3",
          "value" => 3,
          "numberwang" => false,
          "link" => [
            {"rel" => "self", "href" => "http://example.org/number/3"},
            {"rel" => "number", "href" => "http://example.org/number"},
          ],
        }
      end
    end
    context "with errors" do
      before :all do
        Number.truncate
        post "/number", '{}'
      end
      it("status is 422 Unprocessable Entity") { last_response.status.should == 422 }
      it("content-type is application/json") { last_response.content_type.should == "application/json;charset=utf-8" }
      it "body includes urn, link to self and link to collection" do
        hash = Yajl::Parser.parse last_response.body
        hash.should == {
          "value" => nil,
          "numberwang" => false,
          "errors" => {
            "value" => ["can't be blank"],
          }
        }
      end
    end
    context "with invalid serialization" do
      before :all do
        Number.truncate
        post "/number", ','
      end
      it("status is 400 Bad Request") { last_response.status.should == 400 }
      it("content-type is text/html") { last_response.content_type.should == "text/html;charset=utf-8" }
      it "body is empty" do
        last_response.body.should == ""
      end
    end
  end

  context "Index" do
    context "without number" do
      before :all do
        Number.truncate
        get "/number"
      end
      it("status is 200 OK") { last_response.status.should == 200 }
      it("content-type is application/json") { last_response.content_type.should == "application/json;charset=utf-8" }
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
    context "with numbers" do
      before :all do
        Number.truncate
        Number.new("value" => 1).save
        Number.new("value" => 2, "numberwang" => true).save
        get "/number"
      end
      it("status is 200 OK") { last_response.status.should == 200 }
      it("content-type is application/json") { last_response.content_type.should == "application/json;charset=utf-8" }
      it "body contains link to self and all numbers" do
        hash = Yajl::Parser.parse last_response.body
        hash.should == {
          "number" => [
            {
              "urn" => "urn:api:number:1",
              "value" => 1,
              "numberwang" => false,
              "link" => [
                {"rel" => "self", "href" => "http://example.org/number/1"}
              ],
            },
            {
              "urn" => "urn:api:number:2",
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
    context "search" do
      before :all do
        Number.truncate
        Number.new("value" => 1).save
        Number.new("value" => 2).save
        get "/number?odd=1"
      end
      it("status is 200 OK") { last_response.status.should == 200 }
      it("content-type is application/json") { last_response.content_type.should == "application/json;charset=utf-8" }
      it "body contains link to self and matching numbers" do
        hash = Yajl::Parser.parse last_response.body
        hash.should == {
          "number" => [
            {
              "urn" => "urn:api:number:1",
              "value" => 1,
              "numberwang" => false,
              "link" => [
                {"rel" => "self", "href" => "http://example.org/number/1"}
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