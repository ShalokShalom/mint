require "../spec_helper"

describe "Variable" do
  subject variable

  expect_ignore " "
  expect_ignore "."
  expect_ignore "???"

  expect_ok "a"
  expect_ok "asd"
  expect_ok "asdAsd"
  expect_ok "asd_"
end

describe "Variable!" do
  subject variable!(SyntaxError)

  expect_error " ", SyntaxError
  expect_error ".", SyntaxError
  expect_error "???", SyntaxError
end

describe "Variable With Dashes" do
  subject variable_with_dashes

  expect_ignore " "
  expect_ignore "."
  expect_ignore "???"

  expect_ok "a"
  expect_ok "asd-ada-sd---asd"
  expect_ok "asd"
  expect_ok "asdAsd"
  expect_ok "asd_"
end

describe "Variable With Dashes!" do
  subject variable_with_dashes!(SyntaxError)

  expect_error " ", SyntaxError
  expect_error ".", SyntaxError
  expect_error "???", SyntaxError
end
