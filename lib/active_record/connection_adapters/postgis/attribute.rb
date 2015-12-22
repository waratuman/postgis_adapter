# module ActiveRecord
#   class Attribute # :nodoc:
#
#     protected
#
#     # WithCastValue is used in update_columns but when setting a geometry
#     # attribute it does not get sent to the database adapter for type casting
#     # in Rails, so a getter for a geometry will return a string if setting with
#     # a string value. This overrides this by sending any attribute that is not
#     # a serialized attribute to the database adapter for type casting.
#     #
#     # TODO: write these tests
#     # Topic.serialize :content, JSON
#     #
#     # t = Topic.create(content: {"first" => 1})
#     # assert_equal({"first" => 1}, t.content)
#     #
#     # t.update_column(:content, {"first" => 2})
#     # assert_equal({"first" => 2}, t.content)
#     #
#     # @connection.execute "insert into pg_arrays (tags) VALUES ('{1,2,3}')"
#     # x = PgArray.first
#     # x.update_columns(tags: '{1,2,3,4}')
#     # assert_equal ['1','2','3','4'], x.tags
#     # assert_equal ['1','2','3','4'], x.reload.tags
#     #
#     # x.update_columns(tags: ['1'])
#     # assert_equal ['1'], x.tags
#     # assert_equal ['1'], x.reload.tags
#     class WithCastValue < Attribute # :nodoc:
#
#       def type_cast(value)
#         if type.is_a?(ActiveRecord::Type::Serialized)
#           value
#         else
#           type.cast_value(value)
#         end
#       end
#
#       def changed_in_place_from?(old_value)
#         false
#       end
#
#       def changed_from?(old_value)
#         false
#       end
#
#     end
#   end
# end