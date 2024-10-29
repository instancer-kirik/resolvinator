# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Resolvinator.Repo.insert!(%Resolvinator.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# priv/repo/seeds.exs




alias Resolvinator.Repo

alias Resolvinator.Accounts.User
alias Resolvinator.Content.{Problem, Solution, Lesson, Advantage, Gesture, Description, UserHiddenDescription}
# priv/repo/seeds.exs
import Pbkdf2, only: [hash_pwd_salt: 1]

# List of hand gestures with descriptions
gestures_data = [
  %{
    name: "Okay Sign",
    descriptions: [
%Description{ text:
      "A-OK or Okay, made by connecting the thumb and forefinger in a circle and holding the other fingers straight, usually signal the word okay.", descriptionable_type: "Gesture"},
%Description{ text:
      "Considered obscene in Brazil and Turkey.", descriptionable_type: "Gesture"},
%Description{ text:
      "In parts of Europe, it means anal sex to imply the rudeness or arrogance of the recipient.", descriptionable_type: "Gesture"},
%Description{ text:
      "Sometimes associated with the racist theory of white power.", descriptionable_type: "Gesture"},
%Description{ text:
      "In Japanese culture, it is a way of requesting money or payment.", descriptionable_type: "Gesture"}
],
    fingers: "00222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Okay Sign</text>
    </svg>
    """
  },
  %{
    name: "Peace Sign",
    descriptions: [
%Description{ text:
      "A gesture of peace or victory.", descriptionable_type: "Gesture"},
%Description{ text:
      "Also used to signify 'V' for victory.", descriptionable_type: "Gesture"}
],
    fingers: "00200",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Peace Sign</text>
    </svg>
    """
  },
  %{
    name: "Abhayamudra",
    descriptions: [
%Description{ text:
      "A Hindu mudra or gesture of reassurance and safety.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Abhayamudra</text>
    </svg>
    """
  },
  %{
    name: "Apology Hand Gesture",
    descriptions: [
%Description{ text:
      "A Hindu custom to apologize when a person's foot accidentally touches a book or any written material.", descriptionable_type: "Gesture"},
%Description{ text:
      "The offending person touches the object with the fingertips and then the forehead and/or chest.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Apology Hand Gesture</text>
    </svg>
    """
  },
  %{
    name: "Beckoning Sign",
    descriptions: [
%Description{ text:
      "In North America or Northern Europe, made with the index finger sticking out of the clenched fist, palm facing the gesturer.", descriptionable_type: "Gesture"},
%Description{ text:
      "In Northern Africa, calling someone is done using the full hand.", descriptionable_type: "Gesture"},
%Description{ text:
      "In several Asian and European countries, made with a scratching motion with all four fingers and with the palm down.", descriptionable_type: "Gesture"},
%Description{ text:
      "In Japan and other countries in the far-east cultural area, the palm faces the recipient with the hand at head's height.", descriptionable_type: "Gesture"}
],
    fingers: "20000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Beckoning Sign</text>
    </svg>
    """
  },
  %{
    name: "Bellamy Salute",
    descriptions: [
%Description{ text:
      "Used in conjunction with the American Pledge of Allegiance prior to World War II.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Bellamy Salute</text>
    </svg>
    """
  },
  %{
    name: "Bent Index Finger",
    descriptions: [
%Description{ text:
      "This gesture means 'dead' in Chinese culture.", descriptionable_type: "Gesture"}
],
    fingers: "20000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Bent Index Finger</text>
    </svg>
    """
  },
  %{
    name: "Hand of Benediction and Blessing",
    descriptions: [
%Description{ text:
      "A raised right hand with the ring finger and little finger touching the palm, while the middle and index fingers remain raised.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used by Christian clergy to perform blessings with the sign of the cross.", descriptionable_type: "Gesture"},
%Description{ text:
      "The three raised fingers (index, middle, and thumb) represent the three Persons of the Holy Trinity.", descriptionable_type: "Gesture"}
],
    fingers: "22300",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Hand of Benediction and Blessing</text>
    </svg>
    """
  },
  %{
    name: "Blah-Blah",
    descriptions: [
%Description{ text:
      "The fingers are kept straight and together, held horizontal or upwards and bending at the lowest knuckles, while the thumb points downwards.", descriptionable_type: "Gesture"},
%Description{ text:
      "The fingers and thumb snap together repeatedly to suggest a mouth talking.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used to indicate that someone talks too much, gossips, or is boring.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Blah-Blah</text>
    </svg>
    """
  },
  %{
    name: "Check, Please",
    descriptions: [
%Description{ text:
      "Used to mean that a dinner patron wishes to pay the bill and depart.", descriptionable_type: "Gesture"},
%Description{ text:
      "Executed by touching the index finger and thumb together and 'writing' a checkmark, circle, or wavy line in the air.", descriptionable_type: "Gesture"}
],
    fingers: "22220",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Check, Please</text>
    </svg>
    """
  },
  %{
    name: "Clenched Fist",
    descriptions: [
%Description{ text:
      "Used as a gesture of defiance or solidarity.", descriptionable_type: "Gesture"},
%Description{ text:
      "Facing the signer, it threatens physical violence.", descriptionable_type: "Gesture"}
],
    fingers: "00000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Clenched Fist</text>
    </svg>
    """
  },
  %{
    name: "Clinton Thumb",
    descriptions: [
%Description{ text:
      "Used by politicians to provide emphasis in speeches.", descriptionable_type: "Gesture"},
%Description{ text:
      "The thumb leans against the thumb-side portion of the index finger, which is part of a closed fist.", descriptionable_type: "Gesture"},
%Description{ text:
      "Thought to be less threatening than a clenched fist or pointing finger.", descriptionable_type: "Gesture"}
],
    fingers: "21000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Clinton Thumb</text>
    </svg>
    """
  },
  %{
    name: "Crossed Fingers",
    descriptions: [
%Description{ text:
      "Used superstitiously to wish for good luck or to nullify a promise.", descriptionable_type: "Gesture"}
],
    fingers: "20000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Crossed Fingers</text>
    </svg>
    """
  },
  %{
    name: "Cuckoo Sign",
    descriptions: [
%Description{ text:
      "In North America, making a circling motion of the index finger at the ear or temple signifies that the person 'has a screw loose'.", descriptionable_type: "Gesture"}
],
    fingers: "20000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Cuckoo Sign</text>
    </svg>
    """
  },
  %{
    name: "Cuckold's Horns",
    descriptions: [
%Description{ text:
      "Traditionally placed behind an unwitting man (the cuckold) to insult him and represent that his wife is unfaithful.", descriptionable_type: "Gesture"},
%Description{ text:
      "Made with the index and middle fingers spread by a person standing behind the one being insulted.", descriptionable_type: "Gesture"}
],
    fingers: "22000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Cuckold's Horns</text>
    </svg>
    """
  },
  %{
    name: "Dap Greeting",
    descriptions: [
%Description{ text:
      "A fist-to-fist handshake popularized in Western cultures since the 1970s.", descriptionable_type: "Gesture"},
%Description{ text:
      "Related to the fist bump.", descriptionable_type: "Gesture"}
],
    fingers: "00000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Dap Greeting</text>
    </svg>
    """
  },
  %{
    name: "Eyelid Pull",
    descriptions: [
%Description{ text:
      "Where one forefinger is used to pull the lower eyelid further down, and signifies alertness.", descriptionable_type: "Gesture"}
],
    fingers: "20000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Eyelid Pull</text>
    </svg>
    """
  },
  %{
    name: "Fig Sign",
    descriptions: [
%Description{ text:
      "Made with the hand and fingers curled and the thumb thrust between the middle and index fingers.", descriptionable_type: "Gesture"},
%Description{ text:
      "Considered a good luck charm in some areas and an obscene gesture in others%.", descriptionable_type: "Gesture"},
%Description{ text:
      "Historically used as a fertility and good luck charm.", descriptionable_type: "Gesture"}
],
    fingers: "01100",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Fig Sign</text>
    </svg>
    """
  },
  %{
    name: "The Finger",
    descriptions: [
%Description{ text:
      "An extended middle finger with the back of the hand towards the recipient.", descriptionable_type: "Gesture"},
%Description{ text:
      "An obscene hand gesture used in much of Western culture.", descriptionable_type: "Gesture"}
],
    fingers: "01000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">The Finger</text>
    </svg>
    """
  },
  %{
    name: "Finger Gun",
    descriptions: [
%Description{ text:
      "A hand gesture in which the subject uses their hand to mimic a handgun.", descriptionable_type: "Gesture"},
%Description{ text:
      "If pointed to oneself, it may indicate boredom or awkwardness.", descriptionable_type: "Gesture"},
%Description{ text:
      "When pointed to another, it is interpreted as a threat of violence or a sign of acknowledgement.", descriptionable_type: "Gesture"}
],
    fingers: "20000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Finger Gun</text>
    </svg>
    """
  },
  %{
    name: "Finger Heart",
    descriptions: [
%Description{ text:
      "A hand gesture in which the subject has a palm up fist, raises their index finger and brings their thumb over it so as to form a small heart shape.", descriptionable_type: "Gesture"},
%Description{ text:
      "Originates from South Korean culture.", descriptionable_type: "Gesture"}
],
    fingers: "21000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Finger Heart</text>
    </svg>
    """
  },
  %{
    name: "Fist Bump",
    descriptions: [
%Description{ text:
      "Similar to a handshake or high five, used as a symbol of respect.", descriptionable_type: "Gesture"}
],
    fingers: "00000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Fist Bump</text>
    </svg>
    """
  },
  %{
    name: "Fist Pump",
    descriptions: [
%Description{ text:
      "A celebratory gesture in which a closed fist is raised before the torso and subsequently drawn down in a vigorous, swift motion.", descriptionable_type: "Gesture"}
],
    fingers: "00000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Fist Pump</text>
    </svg>
    """
  },
  %{
    name: "Grey Wolf Salute",
    descriptions: [
%Description{ text:
      "A fist with the little finger and index finger raised, depicting head of a wolf.", descriptionable_type: "Gesture"},
%Description{ text:
      "Associated with Turkish nationalism.", descriptionable_type: "Gesture"}
],
    fingers: "22000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Grey Wolf Salute</text>
    </svg>
    """
  },
  %{
    name: "Handshake",
    descriptions: [
%Description{ text:
      "A greeting ritual in which two people grasp each other's hands and may move their grasped hands up and down.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Handshake</text>
    </svg>
    """
  },
  %{
    name: "High Five",
    descriptions: [
%Description{ text:
      "A celebratory ritual in which two people simultaneously raise one hand and then slap these hands together.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">High Five</text>
    </svg>
    """
  },
  %{
    name: "Hitchhiking Gestures",
    descriptions: [
%Description{ text:
      "Including sticking one thumb upward, especially in North America, or pointing an index finger toward the road, to request a ride in an automobile.", descriptionable_type: "Gesture"}
],
    fingers: "20000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Hitchhiking Gestures</text>
    </svg>
    """
  },
  %{
    name: "Horn Sign",
    descriptions: [
%Description{ text:
      "Made by extending the index and little finger straight upward.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used in rock and roll, especially in heavy metal music called 'devil's horns'.", descriptionable_type: "Gesture"},
%Description{ text:
      "Has a vulgar meaning in some Mediterranean Basin countries.", descriptionable_type: "Gesture"}
],
    fingers: "20020",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Horn Sign</text>
    </svg>
    """
  },
  %{
    name: "ILY Sign",
    descriptions: [
%Description{ text:
      "Combines the letters 'I', 'L', and 'Y' from American Sign Language by extending the thumb, index finger, and little finger while the middle and ring finger touch the palm.", descriptionable_type: "Gesture"},
%Description{ text:
      "An informal expression of love.", descriptionable_type: "Gesture"}
],
    fingers: "21020",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">ILY Sign</text>
    </svg>
    """
  },
  %{
    name: "Knocking on Wood",
    descriptions: [
%Description{ text:
      "A superstitious gesture used to ensure that a good thing will continue to occur after it has been acknowledged.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Knocking on Wood</text>
    </svg>
    """
  },
  %{
    name: "Kodály Hand Signs",
    descriptions: [
%Description{ text:
      "A series of visual aids used during singing lessons in the Kodály method.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Kodály Hand Signs</text>
    </svg>
    """
  },
  %{
    name: "Loser",
    descriptions: [
%Description{ text:
      "Made by extending the thumb and forefinger to resemble the shape of an L on the forehead.", descriptionable_type: "Gesture"},
%Description{ text:
      "An insulting gesture.", descriptionable_type: "Gesture"}
],
    fingers: "20000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Loser</text>
    </svg>
    """
  },
  %{
    name: "Mano Pantea",
    descriptions: [
%Description{ text:
      "A traditional way to ward off the evil eye.", descriptionable_type: "Gesture"},
%Description{ text:
      "Made by raising the right hand with the palm out and folding the pinky and ring finger.", descriptionable_type: "Gesture"}
],
    fingers: "22000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Mano Pantea</text>
    </svg>
    """
  },
  %{
    name: "The Mewing Gesture",
    descriptions: [
%Description{ text:
      "Done by extending the index finger and tracing it down the jawline.", descriptionable_type: "Gesture"},
%Description{ text:
      "May also be paired with the shushing gesture.", descriptionable_type: "Gesture"}
],
    fingers: "20000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">The Mewing Gesture</text>
    </svg>
    """
  },
  %{
    name: "The Money Gesture",
    descriptions: [
%Description{ text:
      "Signalled by repeatedly rubbing one's thumb over the tip of the index finger and middle finger.", descriptionable_type: "Gesture"},
%Description{ text:
      "Resembles the act of rubbing coins or bills together and is generally used when speaking about money.", descriptionable_type: "Gesture"}
],
    fingers: "21100",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">The Money Gesture</text>
    </svg>
    """
  },
  %{
    name: "Moutza",
    descriptions: [
%Description{ text:
      "A traditional insult gesture in Greece made by extending all five fingers and presenting the palm or palms toward the person being insulted.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Moutza</text>
    </svg>
    """
  },
  %{
    name: "Nazi Salute",
    descriptions: [
%Description{ text:
      "Used in Germany and Italy during World War II to indicate loyalty to Adolf Hitler or Benito Mussolini.", descriptionable_type: "Gesture"},
%Description{ text:
      "The right arm is raised in a straight diagonal position forward with the palm open facing downward.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Nazi Salute</text>
    </svg>
    """
  },
  %{
    name: "Outstretched Hand",
    descriptions: [
%Description{ text:
      "A near-universal gesture for begging or requesting, extending beyond human cultures and into other primate species.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Outstretched Hand</text>
    </svg>
    """
  },
  %{
    name: "Pointing with Index Finger",
    descriptions: [
%Description{ text:
      "Used to indicate an item or person.", descriptionable_type: "Gesture"}
],
    fingers: "20000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Pointing with Index Finger</text>
    </svg>
    """
  },
  %{
    name: "Raised Fist",
    descriptions: [
%Description{ text:
      "Mostly used by activists to express solidarity and defiance against oppression.", descriptionable_type: "Gesture"}
],
    fingers: "00000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Raised Fist</text>
    </svg>
    """
  },
  %{
    name: "Roman Salute",
    descriptions: [
%Description{ text:
      "A salute made by a small group of people holding their arms outward with fingertips touching.", descriptionable_type: "Gesture"},
%Description{ text:
      "Adopted by the Italian Fascists and likely inspired the Hitler salute.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Roman Salute</text>
    </svg>
    """
  },
  %{
    name: "Salute",
    descriptions: [
%Description{ text:
      "Refers to a number of gestures used to display respect, especially among armed forces.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Salute</text>
    </svg>
    """
  },
  %{
    name: "Scout Handshake",
    descriptions: [
%Description{ text:
      "A left-handed handshake used as a greeting among members of various Scouting organizations.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Scout Handshake</text>
    </svg>
    """
  },
  %{
    name: "Shaka Sign",
    descriptions: [
%Description{ text:
      "Consists of extending the thumb and little finger upward.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used as a gesture of friendship in Hawaii and surf culture.", descriptionable_type: "Gesture"}
],
    fingers: "20020",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Shaka Sign</text>
    </svg>
    """
  },
  %{
    name: "So-So Gesture",
    descriptions: [
%Description{ text:
      "Expresses neutral sentiment or mild dissatisfaction.", descriptionable_type: "Gesture"},
%Description{ text:
      "The hand is held parallel to the ground (face down) and rocked slightly.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">So-So Gesture</text>
    </svg>
    """
  },
  %{
    name: "Talk to the Hand",
    descriptions: [
%Description{ text:
      "An English-language slang expression of contempt popular during the 1990s.", descriptionable_type: "Gesture"},
%Description{ text:
      "The associated hand gesture consists of extending a palm toward the person insulted.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Talk to the Hand</text>
    </svg>
    """
  },
  %{
    name: "Telephone Gesture",
    descriptions: [
%Description{ text:
      "Thumb and little finger outstretched, other fingers tight against palm.", descriptionable_type: "Gesture"},
%Description{ text:
      "Thumb to ear and little finger to mouth as though they were a telephone receiver.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used to say, 'I'll call you', or may be used to request a future telephone conversation.", descriptionable_type: "Gesture"}
],
    fingers: "20020",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Telephone Gesture</text>
    </svg>
    """
  },
  %{
    name: "Two-Finger Salute",
    descriptions: [
%Description{ text:
      "A salute made using the middle and index fingers.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used by Polish Armed Forces and by Cub Scouts.", descriptionable_type: "Gesture"}
],
    fingers: "22000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Two-Finger Salute</text>
    </svg>
    """
  },
  %{
    name: "V Sign",
    descriptions: [
%Description{ text:
      "Made by raising the index and middle fingers and separating them to form a V, usually with the palm facing outwards.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used to indicate 'V for Victory' or to mean 'peace'.", descriptionable_type: "Gesture"}
],
    fingers: "20020",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">V Sign</text>
    </svg>
    """
  },
  %{
    name: "Vulcan Salute",
    descriptions: [
%Description{ text:
      "Used in the television program Star Trek.", descriptionable_type: "Gesture"},
%Description{ text:
      "Consists of all fingers raised and parted between the ring and middle fingers with the thumb sticking out to the side.", descriptionable_type: "Gesture"},
%Description{ text:
      "Devised and popularized by Leonard Nimoy.", descriptionable_type: "Gesture"}
],
    fingers: "22002",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Vulcan Salute</text>
    </svg>
    """
  },
  %{
    name: "Wanker Gesture",
    descriptions: [
%Description{ text:
      "Made by curling the fingers into a loose fist and moving the hand up and down as though masturbating.", descriptionable_type: "Gesture"},
%Description{ text:
      "The gesture has the same meaning as the British slang insult, 'wanker'.", descriptionable_type: "Gesture"}
],
    fingers: "01110",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Wanker Gesture</text>
    </svg>
    """
  },
  %{
    name: "Wave",
    descriptions: [
%Description{ text:
      "A gesture in which the hand is raised and moved left and right, as a greeting or sign of departure.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Wave</text>
    </svg>
    """
  },
  %{
    name: "Añjali Mudrā",
    descriptions: [
%Description{ text:
      "A sign of respect in India and among yoga practitioners.", descriptionable_type: "Gesture"},
%Description{ text:
      "Made by pressing the palms together.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Añjali Mudrā</text>
    </svg>
    """
  },
  %{
    name: "Air Quotes",
    descriptions: [
%Description{ text:
      "Made by raising both hands to eye level and flexing the index and middle fingers of both hands while speaking.", descriptionable_type: "Gesture"},
%Description{ text:
      "Their meaning is similar to that of scare quotes in writing.", descriptionable_type: "Gesture"}
],
    fingers: "22020",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Air Quotes</text>
    </svg>
    """
  },
  %{
    name: "Applause",
    descriptions: [
%Description{ text:
      "An expression of approval made by clapping the hands together to create repetitive staccato noise.", descriptionable_type: "Gesture"},
%Description{ text:
      "Most appropriate within a group setting to collectively show approval by the volume, duration, and clamor of the noise.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Applause</text>
    </svg>
    """
  },
  %{
    name: "Awkward Turtle",
    descriptions: [
%Description{ text:
      "A two-handed gesture used to mark a moment as awkward.", descriptionable_type: "Gesture"},
%Description{ text:
      "One hand is placed flat atop the other with both palms facing down, fingers extended outward from the hand and thumbs stuck out to the sides.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Awkward Turtle</text>
    </svg>
    """
  },
  %{
    name: "Batsu",
    descriptions: [
%Description{ text:
      "In Japanese culture, the batsu (literally: ×-mark) is a gesture made by crossing one's arms in the shape of an 'X' in front of them to indicate that something is 'wrong' or 'no good'.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Batsu</text>
    </svg>
    """
  },
  %{
    name: "Bras d'Honneur",
    descriptions: [
%Description{ text:
      "An obscene gesture made by flexing one elbow while gripping the inside of the bent arm with the opposite hand.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Bras d'Honneur</text>
    </svg>
    """
  },
  %{
    name: "Jazz Hands",
    descriptions: [
%Description{ text:
      "Used in dance or other performances by displaying the palms of both hands with fingers splayed.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Jazz Hands</text>
    </svg>
    """
  },
  %{
    name: "Hand Heart",
    descriptions: [
%Description{ text:
      "A recent pop culture symbol meaning love.", descriptionable_type: "Gesture"},
%Description{ text:
      "The hands form the shape of a heart.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Hand Heart</text>
    </svg>
    """
  },
  %{
    name: "Kung Fu Salute",
    descriptions: [
%Description{ text:
      "A formal demonstration of respect between martial arts practitioners in which the right hand (formed into a fist) is covered by the open left palm.", descriptionable_type: "Gesture"}
],
    fingers: "00000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Kung Fu Salute</text>
    </svg>
    """
  },
  %{
    name: "Mani Giunte",
    descriptions: [
%Description{ text:
      "An Italian gesture used when expressing exasperation or disbelief by putting both palms together in prayer and moving them down and back up towards your chest repeatedly.", descriptionable_type: "Gesture"},
%Description{ text:
      "Also known as the 'Mother of God'.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Mani Giunte</text>
    </svg>
    """
  },
  %{
    name: "Mano a Borsa",
    descriptions: [
%Description{ text:
      "An Italian gesture, used when something is unclear.", descriptionable_type: "Gesture"},
%Description{ text:
      "Created by extending all the digits on the hand bringing them together with palms facing up and moving the hand up and down by the action of the wrist and/or elbow.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Mano a Borsa</text>
    </svg>
    """
  },
  %{
    name: "Maru",
    descriptions: [
%Description{ text:
      "In Japanese culture, a gesture made by holding both arms curved over the head with the hands joined, thus forming a circular shape, to express that something is 'correct' or 'good'.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Maru</text>
    </svg>
    """
  },
  %{
    name: "Merkel-Raute",
    descriptions: [
%Description{ text:
      "The signature gesture of Angela Merkel has become a political symbol used by both her supporters and opponents.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Merkel-Raute</text>
    </svg>
    """
  },
  %{
    name: "Ogham",
    descriptions: [
%Description{ text:
      "Direct evidence for the existence of a system of ogham hand signals.", descriptionable_type: "Gesture"},
%Description{ text:
      "Cossogam involves putting the fingers to the right or left of the shinbone for the first or second aicmi.", descriptionable_type: "Gesture"},
%Description{ text:
      "Sronogam involves the same procedure with the ridge of the nose.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Ogham</text>
    </svg>
    """
  },
  %{
    name: "Open Palms",
    descriptions: [
%Description{ text:
      "A gesture seen in humans and other animals as a psychological and subconscious behaviour in body language to convey trust, openness and compliance.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Open Palms</text>
    </svg>
    """
  },
  %{
    name: "Praying Hands",
    descriptions: [
%Description{ text:
      "A reverent clasping of the hands together, used during prayer in most major religions.", descriptionable_type: "Gesture"},
%Description{ text:
      "The palms of the hands are held together with the fingers extended and touching or the fingers folded upon the opposite hand.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Praying Hands</text>
    </svg>
    """
  },
  %{
    name: "Quenelle",
    descriptions: [
%Description{ text:
      "Created by French comedian Dieudonné M'Bala M'Bala, often associated with anti-Zionism or antisemitic sentiments.", descriptionable_type: "Gesture"},
%Description{ text:
      "Made by touching the shoulder of an outstretched arm with the palm of the other hand.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Quenelle</text>
    </svg>
    """
  },
  %{
    name: "Shame",
    descriptions: [
%Description{ text:
      "In North America, symbolized by rubbing the back of one forefinger with the other forefinger.", descriptionable_type: "Gesture"}
],
    fingers: "22000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Shame</text>
    </svg>
    """
  },
  %{
    name: "TT",
    descriptions: [
%Description{ text:
      "Made by making a fist and extending the thumb and index finger, making an uppercase 'T' shape.", descriptionable_type: "Gesture"},
%Description{ text:
      "Indicates the user is upset or crying, as the sign illustrates tears pooling under the eyes and falling down their face.", descriptionable_type: "Gesture"},
%Description{ text:
      "Derived from South Korea, featured in popular K-pop group Twice (group)'s song called TT (song) and its corresponding dance.", descriptionable_type: "Gesture"}
],
    fingers: "20020",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">TT</text>
    </svg>
    """
  },
  %{
    name: "T-Sign",
    descriptions: [
%Description{ text:
      "Made by holding one hand vertically and tapping the fingertips with the palm of the other hand held horizontally such that the two hands form the shape of the letter T.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used in many sports to request a timeout.", descriptionable_type: "Gesture"}
],
    fingers: "22020",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">T-Sign</text>
    </svg>
    """
  },
  %{
    name: "Victory Clasp",
    descriptions: [
%Description{ text:
      "Used to exclaim victory by clasping one's own hands together and shaking them to one's side to another at, or above, one's head.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Victory Clasp</text>
    </svg>
    """
  },
  %{
    name: "Whatever",
    descriptions: [
%Description{ text:
      "Made with the thumb and forefinger of both hands to form the letter 'W'.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used to signal that something is not worth the time and energy.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Whatever</text>
    </svg>
    """
  },
  %{
    name: "Zoltan",
    descriptions: [
%Description{ text:
      "A sign of faith.", descriptionable_type: "Gesture"},
%Description{ text:
      "Made by placing the tip of one thumb on top of the other, and opening the palms of both hands to form the letter Z.", descriptionable_type: "Gesture"}
],
    fingers: "20020",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Zoltan</text>
    </svg>
    """
  },
  %{
    name: "Akanbe",
    descriptions: [
%Description{ text:
      "Performed by pulling a lower eyelid down to expose the red underneath, often while also sticking out one's tongue.", descriptionable_type: "Gesture"},
%Description{ text:
      "A childish insult in Japanese culture.", descriptionable_type: "Gesture"}
],
    fingers: "20000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Akanbe</text>
    </svg>
    """
  },
  %{
    name: "Butterfly Kissing",
    descriptions: [
%Description{ text:
      "Getting an eye close to another person's eye and fluttering the eyelids rapidly.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used to express love.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Butterfly Kissing</text>
    </svg>
    """
  },
  %{
    name: "Cut-Eye",
    descriptions: [
%Description{ text:
      "A gesture of condemnation in Jamaica and some of North America.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Cut-Eye</text>
    </svg>
    """
  },
  %{
    name: "Eyebrow Raising",
    descriptions: [
%Description{ text:
      "In Marshall Islands culture, briefly raising the eyebrows is used to acknowledge the presence of another person or to signal assent.", descriptionable_type: "Gesture"},
%Description{ text:
      "Commonly used in the Philippines to signal affirmation.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used in various settings for different meanings.", descriptionable_type: "Gesture"}
],
    fingers: "00000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Eyebrow Raising</text>
    </svg>
    """
  },
  %{
    name: "Eye-Rolling",
    descriptions: [
%Description{ text:
      "Performed by rotating the eyes upward and back down.", descriptionable_type: "Gesture"},
%Description{ text:
      "Can indicate incredulity, contempt, boredom, frustration, or exasperation.", descriptionable_type: "Gesture"},
%Description{ text:
      "Occurs in many countries of the world, especially common among adolescents.", descriptionable_type: "Gesture"}
],
    fingers: "00000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Eye-Rolling</text>
    </svg>
    """
  },
  %{
    name: "Air Kiss",
    descriptions: [
%Description{ text:
      "Conveys meanings similar to kissing, but is performed without making bodily contact.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Air Kiss</text>
    </svg>
    """
  },
  %{
    name: "Blowing a Raspberry",
    descriptions: [
%Description{ text:
      "Signifies derision by sticking out the tongue and blowing to create a sound similar to flatulence.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Blowing a Raspberry</text>
    </svg>
    """
  },
  %{
    name: "Cheek Kissing",
    descriptions: [
%Description{ text:
      "Pressing one's lips to another person's cheek.", descriptionable_type: "Gesture"},
%Description{ text:
      "May show friendship or greeting.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Cheek Kissing</text>
    </svg>
    """
  },
  %{
    name: "Duck Face",
    descriptions: [
%Description{ text:
      "A popular gesture among teenagers which involves puckering lips.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used as a 'funny face' when taking pictures.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Duck Face</text>
    </svg>
    """
  },
  %{
    name: "Fish Lips",
    descriptions: [
%Description{ text:
      "Sucking the lips in a manner that makes the mouth look like one of a fish.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Fish Lips</text>
    </svg>
    """
  },
  %{
    name: "Shush",
    descriptions: [
%Description{ text:
      "The index finger of one hand is extended and placed vertically in front of the lips, with the remaining fingers curled toward the palm with the thumb forming a fist.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used to demand or request silence.", descriptionable_type: "Gesture"}
],
    fingers: "20000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Shush</text>
    </svg>
    """
  },
  %{
    name: "Sucking-Teeth",
    descriptions: [
%Description{ text:
      "Also known as Hiss Teeth, Kiss Teeth 'steups' or 'stiups', a gesture used in the West Indies and parts of Africa to signal disagreement, dislike, impatience, annoyance or anger.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Sucking-Teeth</text>
    </svg>
    """
  },
  %{
    name: "Exaggerated Yawning",
    descriptions: [
%Description{ text:
      "Generally with one hand held to the mouth, used to express boredom.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Exaggerated Yawning</text>
    </svg>
    """
  },
  %{
    name: "Anasyrma",
    descriptions: [
%Description{ text:
      "Performed by lifting the skirt or kilt.", descriptionable_type: "Gesture"},
%Description{ text:
      "Used in some religious rituals.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Anasyrma</text>
    </svg>
    """
  },
  %{
    name: "Bowing",
    descriptions: [
%Description{ text:
      "Lowering the torso or head.", descriptionable_type: "Gesture"},
%Description{ text:
      "A show of respect in many cultures.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Bowing</text>
    </svg>
    """
  },
  %{
    name: "Curtsey",
    descriptions: [
%Description{ text:
      "A greeting typically made by women, performed by bending the knees while bowing the head.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Curtsey</text>
    </svg>
    """
  },
  %{
    name: "Davai Vyp'yem",
    descriptions: [
%Description{ text:
      "The index finger is flicked against the side of the neck, just below the jaw.", descriptionable_type: "Gesture"},
%Description{ text:
      "A Russian drinking sign.", descriptionable_type: "Gesture"}
],
    fingers: "20000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Davai Vyp'yem</text>
    </svg>
    """
  },
  %{
    name: "Elbow Bump",
    descriptions: [
%Description{ text:
      "A greeting similar to the handshake or fist bump made by touching elbows.", descriptionable_type: "Gesture"},
%Description{ text:
      "This gesture began to grow in popularity during the COVID-19 pandemic.", descriptionable_type: "Gesture"}
],
    fingers: "00000",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Elbow Bump</text>
    </svg>
    """
  },
  %{
    name: "Eskimo Kissing",
    descriptions: [
%Description{ text:
      "A gesture in Western cultures loosely based on an Inuit greeting, performed by two people touching noses.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Eskimo Kissing</text>
    </svg>
    """
  },
  %{
    name: "Facepalm",
    descriptions: [
%Description{ text:
      "An expression of frustration or embarrassment made by raising the palm of the hand to the face.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Facepalm</text>
    </svg>
    """
  },
  %{
    name: "Genuflection",
    descriptions: [
%Description{ text:
      "A show of respect by bending at least one knee to the ground.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Genuflection</text>
    </svg>
    """
  },
  %{
    name: "Hand-Kissing",
    descriptions: [
%Description{ text:
      "A greeting made by kissing the hand of a person worthy of respect.", descriptionable_type: "Gesture"}
],
    fingers: "22222",
    svg: """
    <svg width="100" height="50">
      <text x="10" y="20" font-family="Arial" font-size="20" fill="black">Hand-Kissing</text>
    </svg>
    """
  }
]

for gesture_data <- gestures_data do
  gesture = %Gesture{
    name: gesture_data.name,
    fingers: gesture_data.fingers,
    svg: gesture_data.svg
  } |> Repo.insert!

  for description_data <- gesture_data.descriptions do
    description = %Description{
      text: description_data.text,
      descriptionable_id: gesture.id,
      descriptionable_type: "Gesture"
    } |> Repo.insert!
  end
end









# Example user with hashed password
hashed_password = hash_pwd_salt("password123")
user1 = Repo.insert!(%User{name: "Exampl1e", email: "example@example.com", hashed_password: hashed_password})
user2 = Repo.insert!(%User{name: "Example", email: "bob@example.com", hashed_password: hashed_password})

# Hide some descriptions for the user
hidden_descriptions = [
  %UserHiddenDescription{user_id: user1.id, description_id: 1},
  %UserHiddenDescription{user_id: user1.id, description_id: 2}
]

Enum.each(hidden_descriptions, fn hidden_description ->
  Repo.insert!(hidden_description)
end)

# Insert Problems
problems = [
  %Problem{
    name: "Problem 1",
    desc: "Description of problem 1",
    user_id: user1.id,
    upvotes: 10,
    downvotes: 2,
    status: "initial"
  },
  %Problem{
    name: "Problem 2",
    desc: "Description of problem 2",
    user_id: user2.id,
    upvotes: 5,
    downvotes: 1,
    status: "initial"
  }
]

problem1 = Repo.insert!(Enum.at(problems, 0))
problem2 = Repo.insert!(Enum.at(problems, 1))

# Insert Solutions
solutions = [
  %Solution{
    name: "Solution 1",
    desc: "Description of solution 1",
    user_id: user1.id,
    upvotes: 8,
    downvotes: 0,
    status: "initial"
  },
  %Solution{
    name: "Solution 2",
    desc: "Description of solution 2",
    user_id: user2.id,
    upvotes: 3,
    downvotes: 2,
    status: "initial"
  }
]

solution1 = Repo.insert!(Enum.at(solutions, 0))
solution2 = Repo.insert!(Enum.at(solutions, 1))

# Insert Lessons
lessons = [
  %Lesson{
    name: "Lesson 1",
    desc: "Description of lesson 1",
    user_id: user1.id,
    upvotes: 7,
    downvotes: 1,
    status: "initial"
  },
  %Lesson{
    name: "Lesson 2",
    desc: "Description of lesson 2",
    user_id: user2.id,
    upvotes: 6,
    downvotes: 0,
    status: "initial"
  }
]

lesson1 = Repo.insert!(Enum.at(lessons, 0))
lesson2 = Repo.insert!(Enum.at(lessons, 1))

# Insert Advantages
advantages = [
  %Advantage{
    name: "Advantage 1",
    desc: "Description of advantage 1",
    user_id: user1.id,
    upvotes: 9,
    downvotes: 1,
    status: "initial"
  },
  %Advantage{
    name: "Advantage 2",
    desc: "Description of advantage 2",
    user_id: user2.id,
    upvotes: 4,
    downvotes: 1,
    status: "initial"
  }
]

advantage1 = Repo.insert!(Enum.at(advantages, 0))
advantage2 = Repo.insert!(Enum.at(advantages, 1))

# Insert Descriptions and associate them with the respective records
descriptions = [
  %Description{text: "Description 1 for problem 1", descriptionable_type: "Problem", descriptionable_id: problem1.id},
  %Description{text: "Description 2 for problem 1", descriptionable_type: "Problem", descriptionable_id: problem1.id},
  %Description{text: "Description 3 for problem 1", descriptionable_type: "Problem", descriptionable_id: problem1.id},
  %Description{text: "Description 4 for problem 1", descriptionable_type: "Problem", descriptionable_id: problem1.id},
  %Description{text: "Description 1 for problem 2", descriptionable_type: "Problem", descriptionable_id: problem2.id},
  %Description{text: "Description 2 for problem 2", descriptionable_type: "Problem", descriptionable_id: problem2.id},
  %Description{text: "Description 1 for solution 1", descriptionable_type: "Solution", descriptionable_id: solution1.id},
  %Description{text: "Description 2 for solution 1", descriptionable_type: "Solution", descriptionable_id: solution1.id},
  %Description{text: "Description 1 for solution 2", descriptionable_type: "Solution", descriptionable_id: solution2.id},
  %Description{text: "Description 2 for solution 2", descriptionable_type: "Solution", descriptionable_id: solution2.id},
  %Description{text: "Description 1 for lesson 1", descriptionable_type: "Lesson", descriptionable_id: lesson1.id},
  %Description{text: "Description 2 for lesson 1", descriptionable_type: "Lesson", descriptionable_id: lesson1.id},
  %Description{text: "Description 1 for lesson 2", descriptionable_type: "Lesson", descriptionable_id: lesson2.id},
  %Description{text: "Description 2 for lesson 2", descriptionable_type: "Lesson", descriptionable_id: lesson2.id},
  %Description{text: "Description 1 for advantage 1", descriptionable_type: "Advantage", descriptionable_id: advantage1.id},
  %Description{text: "Description 2 for advantage 1", descriptionable_type: "Advantage", descriptionable_id: advantage1.id},
  %Description{text: "Description 1 for advantage 2", descriptionable_type: "Advantage", descriptionable_id: advantage2.id},
  %Description{text: "Description 2 for advantage 2", descriptionable_type: "Advantage", descriptionable_id: advantage2.id}
]

Enum.each(descriptions, &Repo.insert!/1)

# Link Problems to Solutions, Lessons, Advantages, and Descriptions with explicit timestamps
now = NaiveDateTime.utc_now()

Repo.insert_all("problem_solution_relationships", [
  %{problem_id: problem1.id, solution_id: solution1.id},
  %{problem_id: problem2.id, solution_id: solution2.id}
])

Repo.insert_all("problem_lesson_relationships", [
  %{problem_id: problem1.id, lesson_id: lesson1.id},
  %{problem_id: problem2.id, lesson_id: lesson2.id}
])

Repo.insert_all("problem_advantage_relationships", [
  %{problem_id: problem1.id, advantage_id: advantage1.id},
  %{problem_id: problem2.id, advantage_id: advantage2.id}
])

Repo.insert_all("problem_descriptions", [
  %{problem_id: problem1.id, description_id: Repo.get_by!(Description, text: "Description 1 for problem 1").id, inserted_at: now, updated_at: now},
  %{problem_id: problem1.id, description_id: Repo.get_by!(Description, text: "Description 2 for problem 1").id, inserted_at: now, updated_at: now},
  %{problem_id: problem1.id, description_id: Repo.get_by!(Description, text: "Description 3 for problem 1").id, inserted_at: now, updated_at: now},
  %{problem_id: problem1.id, description_id: Repo.get_by!(Description, text: "Description 4 for problem 1").id, inserted_at: now, updated_at: now},
  %{problem_id: problem2.id, description_id: Repo.get_by!(Description, text: "Description 1 for problem 2").id, inserted_at: now, updated_at: now},
  %{problem_id: problem2.id, description_id: Repo.get_by!(Description, text: "Description 2 for problem 2").id, inserted_at: now, updated_at: now}
])
