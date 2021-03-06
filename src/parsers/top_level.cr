class Parser
  syntax_error ExpectedEndOfFile

  def self.parse(file) : Ast
    parse File.read(file), file
  end

  def self.parse(contents, file) : Ast
    parser = new(contents, file)
    parser.top_levels
    parser.eof!
    parser.ast
  end

  def eof! : Nil
    whitespace
    raise ExpectedEndOfFile unless char == '\0'
  end

  def top_levels : Nil
    items = many do
      component ||
        module_definition ||
        record_definition ||
        routes ||
        store ||
        provider
    end.compact

    items.each do |item|
      case item
      when Ast::Provider
        @ast.providers << item
      when Ast::RecordDefinition
        @ast.records << item
      when Ast::Component
        @ast.components << item
      when Ast::Module
        @ast.modules << item
      when Ast::Store
        @ast.stores << item
      when Ast::Routes
        @ast.routes << item
      end
    end
  end
end
