class Compiler
  def compile(node : Ast::Component) : String
    compile node.styles, node

    functions =
      compile_component_functions node

    gets =
      compile node.gets

    properties =
      compile node.properties

    name =
      underscorize node.name

    display_name =
      if node.name.includes?('.')
        "\n\n$#{name}.displayName = \"#{node.name}\""
      end

    default_fields =
      node
        .properties
        .map { |prop| "#{prop.name.value}: #{compile prop.default}" }
        .join(",")
        .indent

    defaults =
      if !default_fields.strip.empty?
        "\n\n$#{name}.defaultProps = {\n#{default_fields}\n}"
      end

    store_stuff =
      compile_component_store_data node

    state =
      compile(node.states)
        .first?

    constructor_contents =
      "super(props)\n#{state}"

    constructor =
      if state
        "constructor(props) {\n#{constructor_contents.indent}\n}"
      end

    body =
      ([constructor] + gets + properties + store_stuff + functions)
        .compact
        .join("\n\n")
        .indent

    "class $#{name} extends React.PureComponent {\n#{body}\n}" \
    "#{display_name}#{defaults}"
  end

  def compile_component_store_data(node : Ast::Component) : Array(String)
    node.connects.reduce([] of String) do |memo, item|
      store = ast.stores.find { |store| store.name == item.store }

      if store
        item.keys.map do |key|
          if store.properties.any? { |prop| prop.name.value == key.value }
            memo << "get #{key.value} () { return $#{underscorize(store.name)}.#{key.value} }"
          elsif store.functions.any? { |func| func.name.value == key.value }
            memo << "#{key.value} (...params) { return $#{underscorize(store.name)}.#{key.value}(...params) }"
          end
        end
      end

      memo
    end
  end

  def compile_component_functions(node : Ast::Component) : Array(String)
    heads = {
      "componentWillUnmount" => [] of String,
      "componentDidUpdate"   => [] of String,
      "componentDidMount"    => [] of String,
    }

    node.connects.each do |item|
      name = underscorize item.store
      heads["componentWillUnmount"] << "$#{name}._unsubscribe(this)"
      heads["componentDidMount"] << "$#{name}._subscribe(this)"
    end

    node.uses.each do |use|
      condition = use.condition ? compile(use.condition.not_nil!) : "true"

      body =
        "if (#{condition}) {\n" \
        "  $#{use.provider}._subscribe(this, #{compile use.data})\n" \
        "} else {\n" \
        "  $#{use.provider}._unsubscribe(this)\n" \
        "}"

      heads["componentWillUnmount"] << "$#{use.provider}._unsubscribe(this)"
      heads["componentDidUpdate"] << body
      heads["componentDidMount"] << body
    end

    others =
      node
        .functions
        .reject { |function| heads[function.name.value]? }
        .map { |function| compile(function, "").as(String) }

    specials = heads.map do |key, value|
      function = node.functions.find(&.name.value.==(key))
      if function && value
        compile function, value.join(";")
      elsif value.any?
        "#{key} () {\n#{value.join(";").indent}\n}"
      else
        nil
      end
    end

    (specials + others).compact
  end
end
