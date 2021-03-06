module Qiita
  module Markdown
    class Processor < BaseProcessor
      def self.default_context
        {
          asset_root: "/images",
        }
      end

      def self.default_filters
        [
          Filters::Greenmat,
          Filters::ImageLink,
          Filters::Footnote,
          Filters::Code,
          Filters::Checkbox,
          Filters::Emoji,
          Filters::SyntaxHighlight,
          Filters::Mention,
          Filters::GroupMention,
          Filters::ExternalLink,
          Filters::Sanitize,
        ]
      end
    end
  end
end
