# NOTE: YAMLで特殊な意味の記号を使用できないする。
# 特殊な意味の記号は以下の通り
# - ? : , [ ] { } # & * ! | > ' " % @ `
# \ はエスケープするために使用するため同じく除外
# 残りの記号
# $ ( ) + . / ; < = ^ _ ~

module SafeChar
  extend ActiveSupport::Concern

  class InvalidCharError < StandardError; end

  VALID_CHARS = (("a".."z").to_a + ("0".."9").to_a + %w[$ ( ) + . / ; < = ^ _ ~]).to_set.freeze

  class_methods do
    def check_safe_char(char)
      unless VALID_CHARS.include?(char)
        raise InvalidCharError, "Character must be an alphanumeric or normal symbol: #{char}"
      end
    end
  end
end
