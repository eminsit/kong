local Factory = require "kong.dao.cassandra.factory"
local utils = require "kong.tools.utils"
local spec_helpers = require "spec.spec_helpers"
local env = spec_helpers.get_env()
local default_dao_properties = env.configuration.cassandra

describe("Cassadra factory", function()
  describe("get_session_options()", function()
    local dao_properties
    before_each(function()
      -- TODO switch to new default config getter and shallow copy in feature/postgres
      dao_properties = utils.deep_copy(default_dao_properties)
    end)
    it("should reflect the default config", function()
      local factory = Factory(dao_properties)
      assert.truthy(factory)
      local options = factory:get_session_options()
      assert.truthy(options)
      assert.same({
        shm = "cassandra",
        prepared_shm = "cassandra_prepared",
        contact_points = dao_properties.contact_points,
        keyspace = dao_properties.keyspace,
        query_options = {
          prepare = true
        },
        ssl_options = {
          enabled = false,
          verify = false
        }
      }, options)
    end)
    it("should accept some overriden properties", function()
      dao_properties.contact_points = {"127.0.0.1:9042"}
      dao_properties.keyspace = "my_keyspace"

      local factory = Factory(dao_properties)
      assert.truthy(factory)
      local options = factory:get_session_options()
      assert.truthy(options)
      assert.same({
        shm = "cassandra",
        prepared_shm = "cassandra_prepared",
        contact_points = {"127.0.0.1:9042"},
        keyspace = "my_keyspace",
        query_options = {
          prepare = true
        },
        ssl_options = {
          enabled = false,
          verify = false
        }
      }, options)
    end)
    it("should accept authentication properties", function()
      dao_properties.username = "cassie"
      dao_properties.password = "cassiepwd"

      local factory = Factory(dao_properties)
      assert.truthy(factory)
      local options = factory:get_session_options()
      assert.truthy(options)
      assert.same({
        shm = "cassandra",
        prepared_shm = "cassandra_prepared",
        contact_points = {"127.0.0.1:9042"},
        keyspace = "kong_tests",
        query_options = {
          prepare = true
        },
        ssl_options = {
          enabled = false,
          verify = false
        },
        username = "cassie",
        password = "cassiepwd"
      }, options)
    end)
    it("should accept SSL properties", function()
      dao_properties.contact_points = {"127.0.0.1:9042"}
      dao_properties.ssl.enabled = false
      dao_properties.ssl.verify = true

      local factory = Factory(dao_properties)
      assert.truthy(factory)
      local options = factory:get_session_options()
      assert.truthy(options)
      assert.same({
        shm = "cassandra",
        prepared_shm = "cassandra_prepared",
        contact_points = {"127.0.0.1:9042"},
        keyspace = "kong_tests",
        query_options = {
          prepare = true
        },
        ssl_options = {
          enabled = false,
          verify = true
        }
      }, options)

      -- TEST 2
      dao_properties.ssl.enabled = true
      factory = Factory(dao_properties)
      assert.truthy(factory)
      options = factory:get_session_options()
      assert.truthy(options)
      assert.same({
        shm = "cassandra",
        prepared_shm = "cassandra_prepared",
        contact_points = {"127.0.0.1:9042"},
        keyspace = "kong_tests",
        query_options = {
          prepare = true
        },
        ssl_options = {
          enabled = true,
          verify = true
        }
      }, options)
    end)
  end)
end)
