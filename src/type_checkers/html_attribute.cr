class TypeChecker
  type_error HtmlAttributeComponentPropertyTypeMismatch
  type_error HtmlAttributeElementAttributeTypeMismatch
  type_error HtmlAttributeNotFoundComponentProperty
  type_error HtmlAttributeComponentKeyTypeMismatch
  type_error HtmlElementStyleForbidden

  def check(node : Ast::HtmlAttribute, element : Ast::HtmlElement) : Type
    got =
      check node.value

    expected =
      case node.name.value.downcase
      when "ref"
        REF_FUNCTION
      when .starts_with?("on")
        EVENT_FUNCTION
      when "readonly", "disabled"
        BOOL
      when "style"
        raise HtmlElementStyleForbidden, {
          "node" => node,
        }
      else
        STRING
      end

    raise HtmlAttributeElementAttributeTypeMismatch, {
      "tag"      => element.tag.value,
      "property" => node.name.value,
      "expected" => expected,
      "node"     => node,
      "got"      => got,
    } unless Comparer.compare(expected, got)

    got
  end

  def check(node : Ast::HtmlAttribute, component : Ast::Component) : Type
    type = check node.value

    case node.name.value
    when "key"
      raise HtmlAttributeComponentKeyTypeMismatch, {
        "component" => component.name,
        "expected"  => STRING,
        "got"       => type,
        "node"      => node,
      } unless Comparer.compare(type, STRING)
    else
      prop =
        component
          .properties
          .find(&.name.value.==(node.name.value))

      raise HtmlAttributeNotFoundComponentProperty, {
        "properties" => Snippet.code_list(component.properties.map(&.name.value)),
        "name"       => node.name.value,
        "component"  => component.name,
        "node"       => node,
      } unless prop

      prop_type = check prop

      raise HtmlAttributeComponentPropertyTypeMismatch, {
        "property"  => prop.name.value,
        "component" => component.name,
        "expected"  => prop_type,
        "node"      => node,
        "got"       => type,
      } unless Comparer.compare(prop_type, type)
    end

    type
  end
end
