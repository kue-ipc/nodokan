# バイナリのデータが有るとエラーになる不具合の修正

module RailsAdmin
  module Extensions
    module PaperTrail
      class VersionProxy
        alias _message message
        def message
          @message = @version.event
          if @version.respond_to?(:changeset) && @version.changeset.present?
            result = String.new
            result << @message
            result << " ["
            result << @version.changeset.to_a.collect do |c|
              value = c[1][1].to_s
              value = value.unpack1("H*") if value.encoding == Encoding::ASCII_8BIT
              "#{c[0]} = #{value}"
            end.join(", ")
            result << "]"
            result
          else
            @message
          end
        end
      end
    end
  end
end
