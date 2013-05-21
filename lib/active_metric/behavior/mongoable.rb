module ActiveMetric
  module Mongoable

    def from_db(id, recursive = true)
      collection.find(_id: db_id(id)).one
    end

    def from_parent_in_db(parent_field, parent_id)
      collection.find(parent_field => db_id(parent_id))
    end

    def db_id(string)
      Moped::BSON::ObjectId.from_string(string)
    end

  end
end