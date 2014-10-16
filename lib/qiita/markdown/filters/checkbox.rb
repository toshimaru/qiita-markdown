module Qiita
  module Markdown
    module Filters
      # Converts [ ] and [x] into checkbox elements.
      #
      # * [x] Foo
      # * [ ] Bar
      # * [ ] Baz
      #
      # Takes following context options:
      #
      # * :checkbox_disabled - Pass true to add `disabled` attribute to input element
      #
      class Checkbox < HTML::Pipeline::Filter
        def call
          doc.search("li").each_with_index do |li, index|
            list = List.new(disabled: context[:checkbox_disabled], index: index, node: li)
            list.convert if list.has_checkbox?
          end
          doc
        end

        class List
          include Mem

          CHECKBOX_CLOSE_MARK = "[x] "
          CHECKBOX_OPEN_MARK  = "[ ] "

          def initialize(disabled: nil, index: nil, node: nil)
            @disabled = disabled
            @index = index
            @node = node
          end

          def has_checkbox?
            has_open_checkbox? || has_close_checkbox?
          end

          def convert
            first_text_node.content = first_text_node.content.sub(checkbox_mark, "")
            first_text_node.add_previous_sibling(checkbox_node)
            @node["class"] = "task-list-item"
          end

          private

          def checkbox_mark
            case
            when has_close_checkbox?
              CHECKBOX_CLOSE_MARK
            when has_open_checkbox?
              CHECKBOX_OPEN_MARK
            end
          end

          def checkbox_node
            node = Nokogiri::HTML.fragment('<input type="checkbox" class="task-list-item-checkbox">')
            node.children.first["data-checkbox-index"] = @index
            node.children.first["checked"] = true if has_close_checkbox?
            node.children.first["disabled"] = true if @disabled
            node
          end

          def first_text_node
            @first_text_node ||= begin
              if @node.children.first.name == "p"
                @node.children.first.children.first
              else
                @node.children.first
              end
            end
          end

          memoize\
          def has_close_checkbox?
            @has_close_checkbox = first_text_node.text? && first_text_node.content.start_with?(CHECKBOX_CLOSE_MARK)
          end

          memoize\
          def has_open_checkbox?
            @has_open_checkbox = first_text_node.text? && first_text_node.content.start_with?(CHECKBOX_OPEN_MARK)
          end
        end
      end
    end
  end
end