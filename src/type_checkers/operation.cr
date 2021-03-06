class TypeChecker
  type_error OperationNumericTypeMismatch
  type_error OperationPlusTypeMismatch
  type_error OperationTypeMismatch

  def check(node : Ast::Operation) : Type
    case node.operator
    when "!=", "==", "<", ">", "<=", ">=", "&&", "||"
      right = check node.right
      left = check node.left

      raise OperationTypeMismatch, {
        "right" => right,
        "left"  => left,
        "node"  => node,
      } unless Comparer.compare(left, right)

      BOOL
    when "+"
      right = check node.right
      left = check node.left

      raise OperationPlusTypeMismatch, {
        "side"  => "left",
        "value" => left,
        "node"  => node,
      } unless Comparer.compare(left, NUMBER) ||
               Comparer.compare(left, STRING)

      raise OperationPlusTypeMismatch, {
        "side"  => "right",
        "value" => right,
        "node"  => node,
      } unless Comparer.compare(right, NUMBER) ||
               Comparer.compare(right, STRING)

      raise OperationTypeMismatch, {
        "right" => right,
        "left"  => left,
        "node"  => node,
      } unless Comparer.compare(left, right)

      left
    when "-", "*", "/"
      right = check node.right
      left = check node.left

      raise OperationNumericTypeMismatch, {
        "operator" => node.operator,
        "side"     => "left",
        "value"    => left,
        "node"     => node,
      } unless Comparer.compare(left, NUMBER)

      raise OperationNumericTypeMismatch, {
        "side"     => "right",
        "operator" => node.operator,
        "value"    => right,
        "node"     => node,
      } unless Comparer.compare(right, NUMBER)

      raise OperationTypeMismatch, {
        "right" => right,
        "left"  => left,
        "node"  => node,
      } unless Comparer.compare(left, right)

      NUMBER
    else
      raise TypeError, {} of String => String # Can never happen
    end
  end
end
