require "./spec_helper"

Dir.glob("./spec/formatters/**/*").each do |file|
  it file do
    # Read and separate sample from expected
    sample, expected = File.read(file).split("-"*80)

    # Parse sample
    ast = Parser.parse(sample, file)
    ast.class.should eq(Ast)

    # Type check
    type_checker = TypeChecker.new(ast)
    type_checker.check

    # Format and compare the results
    result = Formatter.new(ast).format
    result.should eq(expected.lstrip)

    # Parse the result, format again and compare
    ast = Parser.parse(result, file)
    ast.class.should eq(Ast)

    result = Formatter.new(ast).format
    result.should eq(expected.lstrip)
  end
end
