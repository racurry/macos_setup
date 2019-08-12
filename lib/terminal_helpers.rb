COLORS = {
  black: 30,
  red: 31,
  green: 32,
  yellow: 33,
  blue: 34,
  pink: 35,
  cyan: 36,
  white: 37
}

STYLES = {
  bold: 1,
  italic: 3,
  underline: 4
}

def section_header(text)
  pputs "-" * 40, style: :bold
  pputs text, style: :bold
  pputs "-" * 40, style: :bold
end

def pprint(text, opts={})
  color = opts[:color]
  style = opts[:style]

  string = text
  string = "\e[#{STYLES[style]}m#{string}\e[0m" if style && STYLES[style]
  string = "\e[#{COLORS[color]}m#{string}\e[0m" if color && COLORS[color]

  print string
end

def pputs(text, opts={})
  pprint(text, opts)
  print "\n"
end