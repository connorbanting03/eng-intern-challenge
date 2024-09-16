english_to_braille = {
  'a' => 'O.....', 'b' => 'O.O...', 'c' => 'OO....', 'd' => 'OO.O..',
  'e' => 'O..O..', 'f' => 'OOO...', 'g' => 'OOOO..', 'h' => 'O.OO..',
  'i' => '.OO...', 'j' => '.OOO..', 'k' => 'O...O.', 'l' => 'O.O.O.',
  'm' => 'OO..O.', 'n' => 'OO.OO.', 'o' => 'O..OO.', 'p' => 'OOO.O.',
  'q' => 'OOOOO.', 'r' => 'O.OOO.', 's' => '.OO.O.', 't' => '.OOOO.',
  'u' => 'O...OO', 'v' => 'O.O.OO', 'w' => '.OOO.O', 'x' => 'OO..OO',
  'y' => 'OO.OOO', 'z' => 'O..OOO', ' ' => '......', 'capital' => '.....O',
  'number' => '.O.OOO'
}

numbers_to_braille = {
  '1' => 'O.....', '2' => 'O.O...', '3' => 'OO....', '4' => 'OO.O..',
  '5' => 'O..O..', '6' => 'OOO...', '7' => 'OOOO..', '8' => 'O.OO..',
  '9' => '.OO...', '0' => '.OOO..'
}



class BrailleToEnglishTranslator
    #Flipping passed in Global Dicts
    def initialize(english_to_braille, numbers_to_braille)
      @braille_to_english = flip_dictionary(english_to_braille)
      @braille_to_numbers = flip_dictionary(numbers_to_braille)
    end
  
    def flip_dictionary(original_dict)
      flipped_dict = {}
      original_dict.each do |key, value|
        flipped_dict[value] = key
      end
      flipped_dict
    end
  
    def call(braille_string)
      words = braille_string.split(@braille_to_english[' ']).map do |braille_word|
        translate_word(braille_word)
      end
      words.join(' ')
    end
  
    def translate_word(braille_word)
      english_translation = ''
      is_number_mode = false
      is_capital_mode = false
      #Breaking brail into it's individual characters 
      braille_word.scan(/.{6}/).each do |braille_char|
        #Setting flags for Brail tags like "Capital" and "Number"
        if 'number' == @braille_to_english[braille_char]
          is_number_mode = true
          next
        elsif 'capital' == @braille_to_english[braille_char]
          is_capital_mode = true
          next
        end
        #Pulling from numbers Dict if numbers flag is set
        if is_number_mode
          english_translation += @braille_to_numbers[braille_char]
          is_number_mode = false
        #If it's not a number than it's a letter in this case
        else
          translated_char = @braille_to_english[braille_char]
          # If capital flag is set -> char will be set to its upper case from
          if is_capital_mode
            translated_char = translated_char.upcase
            is_capital_mode = false
          end
          english_translation += translated_char
        end
      end
  
      english_translation
    end
  end


class EnglishToBrailTranslator
    def initialize(english_to_braille, numbers_to_braille)
        @english_to_braille = english_to_braille
        @numbers_to_braille = numbers_to_braille
    end
    #Splitting up words at the space and translating them one word at a time
    def call(group_of_words)
        group_of_words.split(' ').map do |word|
            translate_word(word)
        end.join(@english_to_braille[' '])
    end
  
    def translate_word(word)
      #If the regex for any number matches the word is considered a number
      if /\d+/.match(word)
        translate_number(word)
      #If the word is not a number it is split an translated to brail one char at a time
      else
        word.split('').map do |char|
          translate_character(char)
        end.join
      end
    end
  
    def translate_number(number_in_letters)
      braille_translation = @english_to_braille['number']
      #Within this function the "number" string is split and mapped one char at a time
      number_in_letters.each_char do |digit|
        braille_translation += @numbers_to_braille[digit]
      end
      braille_translation
    end
  
    def translate_character(character)
      #Regex used to determine if capital brail marker is needed and upper case char is moved to lower case
      if character =~ /[a-z]/
        @english_to_braille[character]
      elsif character =~ /[A-Z]/
        @english_to_braille['capital'] + @english_to_braille[character.downcase]
      else
        ''
      end
    end
end


#Detection for braille to determine which way to translate
def is_braille?(input_text)
    input_text.strip.match?(/\A[O. ]+\z/)
end


if ARGV.empty?
    exit
end

input_text = ARGV.join(' ')
#Logic to determine which translator is used
if is_braille?(input_text)
    translator = BrailToEnglishTranslator.new(english_to_braille, numbers_to_braille)
    english_translation = translator.call(input_text)
    puts english_translation
else
    translator = EnglishToBrailTranslator.new(english_to_braille, numbers_to_braille)
    braille_translation = translator.call(input_text)
    puts braille_translation
end
