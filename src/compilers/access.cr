class Compiler
  def compile(node : Ast::Access) : String
    first =
      compile node.fields.first

    rest =
      node.fields[1..-1].map(&.value)

    ([first] + rest).join(".")
  end
end
