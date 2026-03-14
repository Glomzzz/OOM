#import "/lib/lib.typ": *

#show: schema.with("page",head: [
      #unique[
      #html.tag(
      "link",
      rel: "stylesheet",
      href: "https://fonts.googleapis.com/css2?family=LXGW+WenKai+TC&amp;display=swap",
    )[]
    #html.tag(
      "link",
      rel: "stylesheet",
      href: "https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Source+Sans+3:wght@400;500;600&display=swap",
    )[]
    #html.tag(
      "link",
      rel: "stylesheet",
      href: "/second-person.css",
    )[]
    ]
])

#set text(font: ("Cormorant Garamond", "Source Sans 3", "LXGW WenKai TC"))
#show heading: set text(font: "Cormorant Garamond")

#title[Second Person]
#date[2025-03-14 09:33]
#author[Yorushika]

#let album-url = "https://music.apple.com/my/album/second-person/1876728371"
#let track-embed(url) = html.elem(
  "div",
  attrs: (class: "am-embed"),
)[
  #html.elem(
    "iframe",
    attrs: (
      class: "am-embed__frame am-embed--light",
      src: url,
      allow: "autoplay *; encrypted-media *; fullscreen *; clipboard-write",
      sandbox: "allow-forms allow-popups allow-same-origin allow-scripts allow-top-navigation-by-user-activation",
    ),
  )[]
  #html.elem(
    "iframe",
    attrs: (
      class: "am-embed__frame am-embed--dark",
      src: url + "&theme=dark",
      allow: "autoplay *; encrypted-media *; fullscreen *; clipboard-write",
      sandbox: "allow-forms allow-popups allow-same-origin allow-scripts allow-top-navigation-by-user-activation",
    ),
  )[]
]

= Overview
“To me, an album is a section of a river being held in a moment in time—a collection of leaves floating in place. It’s also a diary that records where I am as a musician right now.” So says Yorushika’s n-buna while speaking to Apple Music about second person, the band’s first album in nearly three years.

Yorushika builds each album around a unique concept, creating work with a strong narrative, and second person continues this trend with a truly novel approach. “I wanted to make something that feels like peeking in on someone’s private correspondence. So, we started by creating a piece of literature in the form of letters—32 envelopes in total—structured so that the reader is looking in on an exchange of letters between two people.”

Taking its inspiration from that work, the album opens with an instrumental track that evokes the image of a person opening a letterbox and breaking the seal on an envelope. “Inside are a boy’s letter to someone he calls ‘teacher’, in which he asks for feedback on his poetry, along with some poems he’s written in his day-to-day life. The whole premise of the album is that those poems have been turned into music.” Guided by his teacher, the boy sets sail into an ocean of words. The journey is endless, filled with inner turmoil, overwhelming loneliness and a succession of vivid scenes.

= Creative cohesion
Although nine of the 22 songs were originally created for other projects, they sit seamlessly within the album, as if they’d been written to be part of the story right from the start. That sense of perfect cohesion can’t be explained through compositional skill alone. It almost feels as if a mysterious musical force within Yorushika, something beyond words, has guided this album into its final form.

“I think the history of Yorushika is really the history of the groove we’ve built as a band, recording with the same musicians since our first album. That’s probably a big part of why we're so committed to recording with live instruments.” With that perspective on Yorushika’s creative journey, n-buna now walks us through the album track by track.

= Listen
#html.elem(
  "div",
  attrs: (class: "am-embed"),
)[
  #html.elem(
    "iframe",
    attrs: (
      class: "am-embed__frame am-embed--light",
      src: "https://embed.music.apple.com/my/album/second-person/1876728371",
      style: "height: 450px;",
      allow: "autoplay *; encrypted-media *; fullscreen *; clipboard-write",
      sandbox: "allow-forms allow-popups allow-same-origin allow-scripts allow-top-navigation-by-user-activation",
    ),
  )[]
  #html.elem(
    "iframe",
    attrs: (
      class: "am-embed__frame am-embed--dark",
      src: "https://embed.music.apple.com/my/album/second-person/1876728371?theme=dark",
      style: "height: 450px;",
      allow: "autoplay *; encrypted-media *; fullscreen *; clipboard-write",
      sandbox: "allow-forms allow-popups allow-same-origin allow-scripts allow-top-navigation-by-user-activation",
    ),
  )[]
]

#link(album-url)[Open in Apple Music]

= Track notes
== Early morning, mailbox
We created this track by layering the instruments in my studio one at a time, rather like a collage, over an audio recording of the actions of retrieving a letter from the letterbox and cutting the envelope open with scissors in the living room. It’s structured to foreshadow the sounds and melodies of the songs that follow.

#track-embed("https://embed.music.apple.com/my/album/early-morning-mailbox/1876728371?i=1876728642")

== Become a cloud
#track-embed("https://embed.music.apple.com/my/album/become-a-cloud/1876728371?i=1876728645")

== The flowers are also noisy
This track emerged out of our efforts to capture the feel of 80s J-Pop with a modern sound. We often listened to Kingo Hamada’s classic J-Pop track ‘midnight cruisin’’ as a reference point while shaping our own sound.

#track-embed("https://embed.music.apple.com/my/album/the-flowers-are-also-noisy/1876728371?i=1876728646")

== Devilishness
The sound design for this one captures the feel of funk and disco. We built the track from a repeating horn phrase. At the time we were writing ‘Devilishness’, we were listening to artists like The Gap Band, Shalamar and Chic a lot. The electric guitar sound on this album came from plugging the guitar straight into a DI called OLLA by Pueblo Audio. That’s what’s behind the hard, direct tone heard on many of the songs, and it’s one of the things that gives this album its sonic consistency.

#track-embed("https://embed.music.apple.com/my/album/devilishness/1876728371?i=1876728647")

== Play Sick
This track features a laid-back horn section. We used a pitch shifter on the trumpet to layer a line an octave above when recording the intro, and for the guitar solo, we used a pitch shifter called the POG2 to improvise a solo shifted an octave up as well. The male voice in the intro is just my own voice taken from a microphone test.

#track-embed("https://embed.music.apple.com/my/album/play-sick/1876728371?i=1876728648")

== Post spring
We tried to record the drums in a rough, raw manner in a very dead room. This track incorporates a deliberate awkwardness, with the drums alone shifting away from the beat. If postmodernism was the springtime of literature, that makes the present day post-postmodern—in other words, post-spring.

#track-embed("https://embed.music.apple.com/my/album/post-spring/1876728371?i=1876728649")

== Sun
This track has its beginnings in lyrics that liken the sun to a butterfly. The strings were recorded by overlaying multiple takes from a quartet. I’ve always loved Sakutaro Hagiwara’s poetry collection, Dreaming of Butterflies, and I keep it within easy reach on my bookshelf.

#track-embed("https://embed.music.apple.com/my/album/sun/1876728371?i=1876728650")

== Sunny
The opening guitar phrase was recorded using a Stratocaster set in the in-between pickup position and run through an old Fender amp. Everything up to the moment of the ending is there to set up the instant when the accompaniment drops out in sync with the final line of the lyrics.

#track-embed("https://embed.music.apple.com/my/album/sunny/1876728371?i=1876728651")

== Forget it
We layered a mandolin over a rhythm pattern stripped down to a bare minimum of stomps and claps. I love the poetry collection Paulownia Blossoms by Hakushu Kitahara, and I drew a lot of inspiration from his work here.

#track-embed("https://embed.music.apple.com/my/album/forget-it/1876728371?i=1876728652")

== Shura
This track combines elements of minimalist funk and soul in its sound and features a bridge-muted guitar tone drenched in reverb to create a sense of floating. It was directly inspired by Kenji Miyazawa’s Spring and Asura.

#track-embed("https://embed.music.apple.com/my/album/shura/1876728371?i=1876728653")

== Martian
This is another minimalist funk track, with the main guitar part played on an old Mosrite. I remember working on the animation for the music video with great enthusiasm.

#track-embed("https://embed.music.apple.com/my/album/martian/1876728371?i=1876728655")

== Rubato
I wrote this song with the image of a dancing woman in mind. We asked Reiya Terakubo—who played trumpet on this album—to improvise freely for the solo in the interlude.

#track-embed("https://embed.music.apple.com/my/album/rubato/1876728371?i=1876728658")

== Cremation
This song features a melody built around the cadence of Japanese lyrics, set over a combination of bossa nova and Cuban rhythms. Its distinctive lilting groove was created using multiple percussion overdubs by Yoshirō Suzuki.

#track-embed("https://embed.music.apple.com/my/album/cremation/1876728371?i=1876728673")

== Aporia
This track likens an endless thirst for knowledge to a rising balloon and is centred around a repeating pattern of 7/8 and 8/8 time signatures. We layered mandolins panned to the left and right to add a sense of space to the chorus.

#track-embed("https://embed.music.apple.com/my/album/aporia/1876728371?i=1876728676")

== Snake
Behind this track is a poem I wrote inspired by a verse by the Chinese poet Yuan Zhen’s, which runs: ‘Once you have seen the great ocean, no other water will do; once you have seen the clouds of Mount Wu, no other clouds will do.’ I imagined myself as a snake emerging from the earth after a long winter.

#track-embed("https://embed.music.apple.com/my/album/snake/1876728371?i=1876728678")

== Groan
Here, I just imagined a low groan, almost like a whisper.

#track-embed("https://embed.music.apple.com/my/album/groan/1876728371?i=1876728679")

== Woodpecker
For this track, there were four of us—acoustic guitar, upright piano, percussion and vocals—all sitting around a microphone. We used the first take, which was recorded during the mic check. I hope the raw, conversational feel of that moment comes through.

#track-embed("https://embed.music.apple.com/my/album/woodpecker/1876728371?i=1876728680")

== Hitchcock (Re-Recording)
This track is a re-recording of a song I wrote some time ago. You could say that the album began with this track, or perhaps that I wrote the song first with the idea of eventually making this concept album already in my mind. We’ve given it the sound it would have if we were to play it now.

#track-embed("https://embed.music.apple.com/my/album/hitchcock-re-recording/1876728371?i=1876728683")

== Moonbath
The lyrics express the passing of time as ‘bathing in moonlight’. The theme imagines me as a fish swimming through it.

#track-embed("https://embed.music.apple.com/my/album/moonbath/1876728371?i=1876728684")

== Plover
One of my favourite Kenji Miyazawa poems contains the line, ‘The wind is calling outside.’ Inspired by that motif, we arranged a soaring horn section with a crisp rhythm guitar for this track.

#track-embed("https://embed.music.apple.com/my/album/plover/1876728371?i=1876728685")

== Paddle
I remember recording the acoustic guitar part in the intro in my studio, playing a Martin guitar through a single AKG C12 mic. One of the themes of this album is anger, and I wanted to respond to that via its music. It seemed inevitable that this would be the closing track. There are no quotations on this song.

#track-embed("https://embed.music.apple.com/my/album/paddle/1876728371?i=1876728686")

== To the sea
I picked up an acoustic guitar at home and recorded this track quite spontaneously. Picturing a sea of sand, I played arpeggios at a tempo that felt right to me, and we ended up using one of the later takes as it was.

#track-embed("https://embed.music.apple.com/my/album/to-the-sea/1876728371?i=1876728687")
