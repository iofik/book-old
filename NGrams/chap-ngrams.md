Chapter 3. N-grams

[Prev](chap-words.xhtml)

[Next](chap-similarity.xhtml)

* * * * *

## Chapter 3. N-grams

**Table of Contents**

[3.1. Introduction](chap-ngrams.xhtml#chap-ngrams-intro)

[3.2. Bigrams](chap-ngrams.xhtml#chap-ngrams-bigrams)

[3.3. A few words on Pattern
Matching](chap-ngrams.xhtml#chap-ngrams-pattern-matching)

[3.4. Collocations](chap-ngrams.xhtml#chap-ngrams-collocations)

[3.5. From bigrams to n-grams](chap-ngrams.xhtml#chap-ngrams-ngrams)

[3.6. Lazy and strict
evaluation](chap-ngrams.xhtml#chap-ngrams-lazy-strict)

[3.7. Suffix arrays](chap-ngrams.xhtml#chap-ngrams-suffixarrays)

[3.8. Markov models](chap-ngrams.xhtml#chap-ngrams-markov-models)

## 3.1. Introduction

In the previous chapter, we have looked at words, and the combination of
words into a higher level of meaning representation: a sentence. As you
might recall being told by your high school grammar teacher, not every
random combination of words forms an grammatically acceptable sentence:

-   Colorless green ideas sleep furiously

-   Furiously sleep ideas green colorless

-   Ideas furiously colorless sleep green

The sentence Colorless green ideas sleep furiously (made famous by the
linguist Noam Chomsky), for instance, is grammatically perfectly
acceptable, but of course entirely nonsensical (unless you ate
wrong/weird mushrooms, that is). If you compare this sentence to the
other two sentences, this grammaticality becomes evident. The sentence
Furiously sleep ideas green colorless is grammatically unacceptable, and
so is Ideas furiously colorless sleep green: these sentences do not play
by the rules of the English language. In other words, the fact that
languages have rules constraints the way in which words can be combined
into an acceptable sentences.

Hey! That sounds good for us NLP programmers (we can almost hear you
think), language plays by rules, computers work with rules, well, we’re
done, aren’t we? We’ll infer a set of rules, and there! we have
ourselves language model. A model that describes how a language, say
English, works and behaves. Well, not so fast buster! Although we will
certainly discuss our share of such rule-based language models later on
(in the chapter about parsing), the fact is that nature is simply not so
simple. The rules by which a language plays are very complex, and no
full set of rules to describe a language has ever been proposed. Bummer,
isn’t it? Lucky for us, there are simpler ways to obtain a language
model, namely by exploiting the observation that words do not combine in
a random order. That is, we can learn a lot from a word and its
neighbors. Language models that exploit the ordering of words, are
called n-gram language models, in which the n represents any integer
greater than zero.

N-gram models can be imagined as placing a small window over a sentence
or a text, in which only n words are visible at the same time. The
simplest n-gram model is therefore a so-called unigram model. This is a
model in which we only look at one word at a time. The sentence
Colorless green ideas sleep furiously, for instance, contains five
unigrams: “colorless”, “green”, “ideas”, “sleep”, and “furiously”. Of
course, this is not very informative, as these are just the words that
form the sentence. In fact, N-grams start to become interesting when n
is two (a bigram) or greater. Let us start with bigrams.

## 3.2. Bigrams

An unigram can be thought of as a window placed over a text, such that
we only look at one word at a time. In similar fashion, a bigram can be
thought of as a window that shows two words at a time. The sentence
Colorless green ideas sleep furiously contains four bigrams:

-   Colorless, green

-   green, ideas

-   ideas, sleep

-   sleep, furiously

To stick to our ‘window’ analogy, we could say that all bigrams of a
sentence can be found by placing a window on its first two words, and by
moving this window to the right one word at a time in a stepwise manner.
We then repeat this procedure, until the window covers the last two
words of a sentence. In fact, the same holds for unigrams and N-grams
with n greater than two. So, say we have a body of text represented as a
list of words or tokens (whatever you prefer). For the sake of legacy,
we will stick to a list of tokens representing the sentence Colorless
green ideas sleep furiously:

~~~~ {.haskell}
Prelude> ["Colorless", "green", "ideas", "sleep", "furiously"]
["Colorless","green","ideas","sleep","furiously"]
~~~~

Hey! That looks like… indeed, that looks like a list of unigrams! Well,
that was convenient. Unfortunately, things do not remain so simple if we
move from unigrams to bigrams or some-very-large-n-grams. Bigrams and
n-grams require us to construct 'windows' that cover more than one word
at a time. In case of bigrams, for instance, this means that we would
like to obtain a list of lists of two words (bigrams). Represented in
such a way, the list of bigrams in the sentence Colorless green ideas
sleep furiously would look like this:

~~~~ {.haskell}
[["Colorless","green"],["green","ideas"],["ideas","sleep"],["sleep","furiously"]]
~~~~

To arrive at such a list, we could start out with a list of words (yes
indeed, the unigrams), and complete the following sequence of steps:

1.  Place a window on the first bigram, and add it to our bigram list

2.  Move the window one word to the right

3.  Repeat from the first step, until the last bigram is stored

Provided these steps, we first need a way to place a window on the first
bigram, that is, we need to isolate the first two items of the list of
words. In its prelude, Haskell defines a function named take that seems
to suit our needs:

~~~~ {.haskell}
Prelude> :type take 
take :: Int -> [a] -> [a]
~~~~

This function takes an Integer denoting n number of elements, and a list
of some type a. Given these arguments, it returns the first n elements
of a list of as. Thus, passing it the number two and a list of words
should give us... our first bigram:

~~~~ {.haskell}
Prelude> take 2 ["Colorless", "green", "ideas", "sleep", "furiously"]
["Colorless","green"]
~~~~

Great! That worked out nice! Now from here on, the idea is to add this
bigram to a list, and to move the window one word to the right, so that
we obtain the second bigram. Let us first turn to the latter (as we will
get the list part for free later on). How do we move the window one word
to the right? That is, how do we extract the second and third word in
the list, instead of the first and second? A possible would be to use
Haskell's !! operator:

~~~~ {.haskell}
Prelude> :t (!!)
(!!) :: [a] -> Int -> a
~~~~

This operator takes a list of as, and returns the nth element;

~~~~ {.haskell}
Prelude> ["Colorless", "green", "ideas", "sleep", "furiously"] !! 1 
"green"
Prelude> ["Colorless", "green", "ideas", "sleep", "furiously"] !! 2 
"ideas"
~~~~

Great, this gives us the two words that make up the second bigram. Now
all we have to do is stuff them together in a list:

~~~~ {.haskell}
Prelude> ["Colorless", "green", "ideas", "sleep", "furiously"] !! 1 : 
["Colorless", "green", "ideas", "sleep", "furiously"] !! 2 : [] 
["green","ideas"]
~~~~

Well, this does the trick. However, it is not very convenient to wrap
this up in a function, and moreover, this approach is not very
Haskellish. In fact, there is a better and more elegant solution, namely
to move the list instead of the window. Wait! What? Yes, move the list
instead of the window. But how? Well, we could just look at the first
and second word in the list again, after getting rid of the (previous)
first word. In other words, we could look at the first two words of the
tail of the list of words:

~~~~ {.haskell}
Prelude> take 2 (tail ["Colorless", "green", "ideas", "sleep", "furiously"])
["green","ideas"]
~~~~

Now that looks Haskellish! What about the next bigram? and the one after
that? Well, we could apply the same trick over and over again. We can
look at the first two words of the tail of the tails of the list of
words:

~~~~ {.haskell}
Prelude> take 2 (tail (tail ["Colorless", "green", "ideas", "sleep", "furiously"]))
["ideas","sleep"]
~~~~

... and the tail of the tail of the tail of the list of words:

~~~~ {.haskell}
Prelude> take 2 (tail (tail (tail ["Colorless", "green", "ideas", "sleep", "furiously"])))
["sleep","furiously"]
~~~~

In fact, that last step already gives us the last bigrams in the
sentence Colorless green ideas sleep furiously. The last step would be
to throw all these two word lists in a larger list, and we have
ourselves a list of bigrams. However, whereas this is manageable by hand
for this particular example, think about obtaining all the bigrams in
the Brown corpus in this manner (gives you nightmares, doesn't it?).
Indeed, we would rather like to wrap this approach up in a function that
does all the hard word for us. Provided a list, this function should
take its first two arguments, and then repetitively do this for the tail
of this, and the tail of the tail of this list, and so forth. In other
words, it should simply constantly take the first bigram of a list, and
do the same for its tail:

~~~~ {.programlisting}
bigram :: [a] -> [[a]]
bigram xs = take 2 xs : bigram (tail xs)
~~~~

Wow! That almost looks like black magic, doesn't it? The type signature
reveals that the function bigram takes a list of as, and returns a list
of list of as. The latter could be a list of bigrams, so this looks
promising. The function takes the first two elements of the list of as,
and places them in front of the result of applying the same function to
the tail of the list of as. Eehh.. what? Congratulations! You have just
seen your first share of recursion magic (or madness). A recursive
function is a function that calls itself, and whereas it might look
dazzling on first sight, this function actually does nothing more than
what we have done by hand in the above. It collects the first two
elements of a list, and then does the same for the tail of this list.
Moreover, it stuffs the two word lists in a larger list on the fly (we
told you the list stuff would come in for free, didn't we?). But wait,
will this work? Well, let us put it to a test:

~~~~ {.haskell}
Prelude> bigram ["Colorless", "green", "ideas", "sleep", "furiously"]
[["Colorless","green"],["green","ideas"],["ideas","sleep"],["sleep","furiously"],
["furiously"],[],*** Exception: Prelude.tail: empty list
~~~~

And the answer is... almost! The function gives us the four bigrams, but
it seems to be too greedy: it does not stop looking for bigrams after
collecting the last bigram in the list of words. But did we tell it when
to stop then? Nope, we didn't. In fact, we have only specified a
so-called recursive step of our recursive function. What we miss is what
is called a stop condition (also known as a base case). In a recursive
definition, a stop condition defines when a function should stop calling
itself, that is, when our recursive problem is solved. In absence of a
stop condition, a recursive function will keep calling itself for
eternity. In fact, this explains above the error, we didn't specify a
stop condition so the function will keep looking for bigrams for
eternity. However, as the list of words is finite, the function will run
into trouble when trying to look for bigrams in the tail of an empty
list, and this is exactly what the exception tells us. So, how to fix
it? Well, add a stop condition that specifies that we should stop
looking for bigrams when the tail of a list contains only one item (as
it is difficult to construct a bigram out of only one word). We could do
this using an if..then..else structure:

~~~~ {.programlisting}
bigram :: [a] -> [[a]]
bigram xs = if length(xs) >= 2
    then take 2 xs : bigram (tail xs)
    else []
~~~~

This should solve our problems:

~~~~ {.haskell}
Prelude> bigram ["Colorless", "green", "ideas", "sleep", "furiously"]
[["Colorless","green"],["green","ideas"],["ideas","sleep"],["sleep","furiously"]]
~~~~

And, indeed it does. When there is only one word left in our list of
words, the bigram function returns an empty list, and moreover, it will
stop calling itself therewith ending the recursion. So, lets see how
this works with an artificial example. First we will recursively apply
the bigram function until it is applied to a list that has less than two
elements:

~~~~ {.haskell}
Prelude> bigram [1,2,3,4]
bigram [1,2,3,4] = [1,2] : bigram (tail [1,2,3,4])
bigram [2,3,4] = [2,3] : bigram (tail [2,3,4])
bigram [3,4] = [3,4] : bigram (tail [3,4])
bigram [4] = []
~~~~

Application of the bigram function to a list with less than two elements
results in an empty list. Moreover, the bigram function will not be
applied recursively again as we have reached our stop condition. Now,
the only thing that remains is to unwind the recursion. That is, we have
called the bigram function from within itself for three times, and as we
have just found the result to its third and last self call, we can now
reversely construct the result of the outermost function call:

~~~~ {.haskell}
bigram [3,4] = [3,4] : []
bigram [2,3,4] = [2,3] : [3,4] : []
bigram [1,2,3,4] = [1,2] : [2,3] : [3,4] : []
[[1,2],[2,3],[3,4]]
~~~~

Great! Are you still with us? As L. Peter Deutsch put it: "to iterate is
human, to recurse divine." Whereas recursive definitions may seem
difficult on first sight, you will find they are very powerful once you
get the hang of them. In fact, they are very common in Haskell, and this
will certainly be the first of many to come in the course of this book.
Lets stick to the bigram function a little longer, because whereas the
above works, it is aesthetically unpleasing. That is, we used an
if..then..else structure to define our stop condition, but Haskell
provides a more elegant way to do this through so-called pattern
matching. Pattern matching can be thought of as defining multiple
definition of the same functions, each tailored and honed for a specific
argument pattern. Provided an argument, Haskell will then pick the first
matching definition of a function, and return the result its
application. Hence, we can define patterns for the stop condition and
recursive step as follows:

~~~~ {.programlisting}
bigram :: [a] -> [[a]]
bigram [x] = []
bigram xs  = take 2 xs : bigram (tail xs)
~~~~

The second line represents the stop condition, and the third the
familiar recursive step. Provided the list of words in the sentence
Colorless green ideas sleep furiously, Haskell will match this to the
recursive step, and apply this definition of the function to the list.
When the recursive step calls the bigram function with a list that
contains only one word (indeed, the tail of the list containing the last
bigram), Haskell will match this call with the stop condition. The
result of this call will simply an empty list. Lets first proof that
this indeed works:

~~~~ {.haskell}
Prelude> bigram ["Colorless", "green", "ideas", "sleep", "furiously"]
[["Colorless","green"],["green","ideas"],["ideas","sleep"],["sleep","furiously"]]
~~~~

It did! To make the working of the use of pattern matching more
insightful we can again write out an artificial example in steps:

~~~~ {.haskell}
Prelude> bigram [1,2,3,4]
bigram [1,2,3,4] = [1,2] : bigram (tail [1,2,3,4])
bigram [2,3,4] = [2,3] : bigram (tail [2,3,4])
bigram [3,4] = [3,4] : bigram (tail [3,4])
bigram [4] = []
bigram [3,4] = [3,4] : []
bigram [2,3,4] = [2,3] : [3,4] : []
bigram [1,2,3,4] = [1,2] : [2,3] : [3,4] : []
[[1,2],[2,3],[3,4]]
~~~~

Check? We are almost there now. There two things left that we should
look at before we mark our function as production ready. The first is a
tiny aesthetically unpleasing detail. In the pattern of our step
condition we use the variable x, whereas we do not use this variable in
the body of the function. It is therefore not necessary to bind the list
element to this variable. Fortunately, Haskell provides a pattern that
matches anything, without doing binding. This pattern is represented by
an underscore. Using this underscore, we can patch up the aesthetics of
our function:

~~~~ {.programlisting}
bigram :: [a] -> [[a]]
bigram [_] = []
bigram xs  = take 2 xs : bigram (tail xs)
~~~~

Secondly, our function fails if we apply it to an empty list:

~~~~ {.haskell}
Prelude> bigram []
[[]*** Exception: Prelude.tail: empty list
~~~~

But hey! That error message looks familiar, doesn't it? Our function
fails, again because we attempted to extract a bigram from the tail of
an empty list. Indeed, an empty list does not match with the pattern of
our stop condition, and therefore the recursive step is applied to it.
We can solve this by adding a pattern for an empty list:

~~~~ {.programlisting}
bigram :: [a] -> [[a]]
bigram []  = []
bigram [_] = []
bigram xs  = take 2 xs : bigram (tail xs)
~~~~

This new pattern basically states that the list of a bigrams of an empty
word list is in turn an empty list. This assures that our function will
not fail when applied to an empty list:

~~~~ {.haskell}
Prelude> bigram []
[]
~~~~

If you want to get really fancy, you could also use pattern matching to
extract a bigram, rather than using `take`{.function}:

~~~~ {.programlisting}
bigram' :: [a] -> [[a]]
bigram' (x:y:xs) = [x,y] : bigram' (y:xs)
bigram' _        = []
~~~~

Now, we only need to account for two patterns: the first pattern matches
when the list has at least two elements. The second pattern matches the
empty list and the list containing just one element.

Good, we are all set! We have our bigram function now... time for some
applications of a bigram language model!

### 3.2.1. Exercises

1.  A skip-bigram is any pair of words in sentence order. Write a
    function `skipBigrams`{.function} that extracts skip-bigrams from a
    sentence as a list of binary tuples, using explicit recursion.
    Running your function on *["Colorless", "green", "ideas", "sleep",
    "furiously"]* should give the following output:

~~~~ {.haskell}
Prelude> skipBigrams ["Colorless", "green", "ideas", "sleep", "furiously"]
[("Colorless","green"),("Colorless","ideas"),("Colorless","sleep"),
("Colorless","furiously"),("green","ideas"),("green","sleep"),
("green","furiously"),("ideas","sleep"),("ideas","furiously"),
("sleep","furiously")]
~~~~

## 3.3. A few words on Pattern Matching

Stub

## 3.4. Collocations

A straightforward application of bigrams is the identification of
so-called collocations. Recall that bigram language models exploit the
observations that words do not simply combine in any random order, that
is, word order is constraint by grammatical structure. However, some
combinations of words are subject to an additional law of constraint.
This law enforces a combination of two words to occur relatively more
often together than in absence of each other. Such combinations are
commonly known as collocations. Depending on the corpus, examples of
collocations are:

-   United States

-   vice president

-   chief executive

Corpus linguists study such collocations to answer interesting questions
about the combinatory properties of words. An example of such a question
concerns the combination of verbs and prepositions: does the verb to
govern occur more often in combination with the preposition by than with
the preposition with?.

In the present section, we will investigate collocations in the Brown
corpus. But before we do so, we first turn to the question of how to
identify collocations. A simple but effective approach to collocation
identification is to compare the observed chance of observing a
combination of two words to the expected chance. How does this work?
Well, say we have a 1000 word corpus in which the word vice occurs 50
times, and the word president 100 times. In other words, the chance that
a randomly picked word is the word vice is p(vice) = 50/1000 = 0.05. In
similar fashion, the chance that randomly picked word is the word
president is p(president) = 100/1000 = 0.1. Now what would be the chance
of observing the combination vice president if the word vice and
president were "unrelated"? Well, this would simply be the chance of
observing the word vice multiplied by the chance of observing the word
president. Thus, p(vice president) = 0.05 x 0.01 = 0.005. From our
thousand word corpus, we can extract 1000 - 1 = 999 bigrams. Assume that
the bigram vice president occurs 40 times, meaning that the chance of
observing this combination in our corpus is p(vice president) = 40 / 999
= 0.04. This reveals the observed chance of observing the combination
vice president is larger than the expected chance. In fact we can
quantify this difference in observed and expected chance for any two
words W1 and W2:

**Equation 3.1. Difference between observed and expected chance**

p(W1W2) p(W1)p(W2) = p(vice president) p(vice)p(president) = 0.04 0.005
= 8

\

The observed chance of observing the combination vice president is eight
times larger than the expected chance of observing this combination. The
difference between the observed and expected chance will be large for
words that occur together a lot of times, whereas it will be small for
words that also occur relatively often independent of each other.

Provided this measure of difference between the observed and expected
chance, we can identify the strongest collocations in a corpus by means
of three steps:

1.  Extract all the bigrams from the corpus

2.  Compute the difference between the observed and expected chance for
    each bigram

3.  Rank the bigrams based on these differences

The bigrams with the highest difference between observed and expected
chance reflect the strongest collocations. However, the difference
between observed and expected chances might easily become very large. To
condense these difference values, we can represent them in logarithmic
space. By doing so, we have stumbled upon a very frequent used measure
of association: the so-called Pointwise Mutual Information (PMI). The
PMI value for the combination of the vice president is:

**Equation 3.2. Pointwise mutual information**

PMI(W1W2) = log p(W1W2) p(W1)p(W2) = log p(vice president)
p(vice)p(president) = log 0.04 0.005 = 2.08

\

Provided this association measure, we can replace step two in three
steps above with: compute the PMI between the obseved and expected
chance for each bigram.

Now that we know how to identify collocations, we can apply our
knowledge to the Brown corpus. First we have to read in the contents of
this corpus like we learned in the previous chapter:

~~~~ {.haskell}
*Main> h <- IO.openFile "brown.txt" IO.ReadMode
*Main> c <- IO.hGetContents h
~~~~

Good! From here on, let us first obtain a list of bigrams for this
corpus:

~~~~ {.haskell}
*Main> let bgs = bigrams (words c)
*Main> head bgs
["The","Fulton"]
~~~~

As a sanity check, we could verify whether we indeed obtained all the
bigrams in the corpus. For a corpus of n words, we expect n-1 bigrams:

~~~~ {.haskell}
*Main> length (words c)
1165170
*Main> length bgs
1165169
~~~~

That looks great! Next we need to determine the relative frequency of
each of these bigrams in the corpus. That is, for each bigram we need to
determine the observed chance of observing it. We could start by
determining the frequency of each bigram. We can reuse the freqList
function defined in the previous chapter to so:

~~~~ {.haskell}
*Main> Data.Map.lookup ["United","States"] (freqList bgs)
Just 392
~~~~

Todo: finish this section

## 3.5. From bigrams to n-grams

While extracting collocations from the Brown corpus, we have seen how
useful bigrams actually are. But at this point you may be clamoring for
the extraction of collocations of three or more words. For this and many
other tasks, it is useful to extract so-called n-grams for an arbitrary
n. We can easily modify our definition of bigrams to extract n-grams a
specified length. Rather than always `take`{.function}ing two elements,
we make the number of items to take an argument to the function:

~~~~ {.programlisting}
ngrams :: Int -> [a] -> [[a]]
ngrams 0 _  = []
ngrams _ [] = []
ngrams n xs
  | length ngram == n = ngram : ngrams n (tail xs)
  | otherwise         = []
  where
    ngram = take n xs
~~~~

We also cannot use pattern matching to exclude the tail when it is
shorter than *n*. Instead, we add a guard that ends the recursion if we
cannot get the proper number of elements from the list. This function
works as you would expect:

~~~~ {.haskell}
Prelude> ngrams 3 [1..10]
[[1,2,3],[2,3,4],[3,4,5],[4,5,6],
 [5,6,7],[6,7,8],[7,8,9],[8,9,10]]
Prelude> ngrams 8 [1..10]
[[1,2,3,4,5,6,7,8],[2,3,4,5,6,7,8,9],
 [3,4,5,6,7,8,9,10]]
~~~~

Since this is barely worth a section, we will take this opportunity to
show two other implementations of the `ngrams`{.function} function. The
first will be more declarative than the definition above, the second
will make use of a monad that we have not used yet: the list monad.

### 3.5.1. A declarative definition of ngrams

Some patterns emerge in the recursive definition of `ngrams`{.function}
that correspond to functions in the *Data.List* module:

1.  Every recursive call uses the tail of the list. In other words, we
    enumerate every tail of the list, including the complete list. The
    `Data.List.tails`{.function} function provides exactly this
    functionality.

2.  We extract the first *n* elements from every tail. This is a mapping
    over the data that could be performed with the `map`{.function}
    function.

3.  The guards in the recursive case amount to filtering lists that do
    not have length *n*. Such filtering can also be performed by the
    `filter`{.function} function.

Let's go through each of these patterns to compose a declarative
definition of `ngrams`{.function}. First, we extract the tails from the
list, using the `tails`{.function} function:

~~~~ {.haskell}
Prelude> import Data.List
Prelude Data.List> let sent = ["Colorless", "green", "ideas", "sleep", "furiously"]
Prelude Data.List> tails sent
[["Colorless","green","ideas","sleep","furiously"],
["green","ideas","sleep","furiously"],["ideas","sleep","furiously"],
["sleep","furiously"],["furiously"],[]]
~~~~

This gives us a list of tails, including the complete sentence. Now, we
`map`{.function} `take`{.function} over each tail to extract an n-gram.
Since `take`{.function} requires two arguments, we use currying to bind
the first argument. For now. we will use `take 2`{.function} to extract
bigrams:

~~~~ {.haskell}
Prelude Data.List> map (take 2) $ tails sent
[["Colorless","green"],["green","ideas"],["ideas","sleep"],["sleep","furiously"],["furiously"],[]]
~~~~

This comes close to a list of bigrams, except that we have an empty list
and a list with just one member dangling at the end. These anomalies are
perfect candidates to be filtered out, so we use the `filter`{.function}
function in conjunction with the `length`{.function} function to exclude
any element that is not of the given length. To accomplish this, we
apply some currying awesomeness. Remember that we can convert infix
operators to prefix operators by adding parentheses:

~~~~ {.haskell}
Prelude Data.List> (==) 2 2
True
Prelude Data.List> (==) 2 3
False
~~~~

This shows that `==`{.function} is just an ordinary function, that just
happens to use the infix notation for convenience. Since this is an
ordinary function, we can also apply currying:

~~~~ {.haskell}
Prelude Data.List> let isTwo = (==) 2
Prelude Data.List> isTwo 2
True
Prelude Data.List> isTwo 3
False
~~~~

Ok, so we want to check whether a list has two elements, so we could
just apply `isTwo`{.function} to the result of the `length`{.function}
function:

~~~~ {.haskell}
Prelude Data.List> isTwo (length ["Colorless","green"])
True
Prelude Data.List> isTwo (length [])
False
~~~~

Or, written as a function definition:

~~~~ {.programlisting}
hasLengthTwo l = isTwo (length l)
~~~~

Since this function follows the canonical form *f (g x)*, we can use
function composition:

~~~~ {.haskell}
Prelude Data.List> let hasLengthTwo = isTwo . length
Prelude Data.List> hasLengthTwo ["Colorless","green"]
True
~~~~

Our filtering expression, *(==) 2 . length*, turns out to be quite
compact. Time to test this with our not-yet-correct list of bigrams:

~~~~ {.haskell}
Prelude Data.List> filter ((==) 2 . length) $ map (take 2) $ tails sent
[["Colorless","green"],["green","ideas"],["ideas","sleep"],["sleep","furiously"]]
~~~~

And this corresponds to the output we expected. So, we can now wrap this
expression in a function, replacing *2* by *n*:

~~~~ {.programlisting}
ngrams' :: Int -> [b] -> [[b]]
ngrams' n = filter ((==) n . length) . map (take n) . tails
~~~~

This function is equivalent to `ngrams`{.function} for all given lists.

You may wonder why this exercise is worthwhile. The reason is that the
declarativeness of `ngrams'`{.function} makes the function much easier
to read. We can almost immediately see what this function does by
reading its body right-to-left, while the recursive definition requires
a closer look. You will notice that, as you get more familiar with
Haskell, it will become easier to spot such patterns in functions.

### 3.5.2. A monadic definition of ngrams

As discussed in the previous chapter, each type that belongs to the
`Monad`{.classname} typeclass provides the `(>>=)`{.function} function
to combine expressions resulting in that type. The list type also
belongs to the monad type class. In GHCi, you can use the **:info**
command to list the type classes to which a type belongs:

~~~~ {.haskell}
Prelude> :i []
data [] a = [] | a : [a]    -- Defined in GHC.Types
instance Eq a => Eq [a] -- Defined in GHC.Classes
instance Monad [] -- Defined in GHC.Base
instance Functor [] -- Defined in GHC.Base
instance Ord a => Ord [a] -- Defined in GHC.Classes
instance Read a => Read [a] -- Defined in GHC.Read
instance Show a => Show [a] -- Defined in GHC.Show
~~~~

The third line of the output shows that lists belong to the
`Monad`{.classname} type class. But how does the `(>>=)`{.function}
function combine expressions resulting in a list? A quick peek at its
definition for the list type reveals this:

~~~~ {.programlisting}
instance Monad [] where
  m >>= k = foldr ((++) . k) [] m
  [...]
~~~~

So, the join operation takes a list *m*, applies a function
`k`{.function} to each element and concatenates the results. Of course,
this concatenation implies that `k`{.function} itself should evaluate to
a list, making the type signature of *k* as follows:
`k ::                     a -> [a]`{.function}

We will illustrate this with an example. Suppose that we would want to
calculate the immediate predecessor and successor of every number in the
list *[0..9]*. In this case, we could use the function
`\x -> [x-1,x+1]`{.function} in the list monad:

~~~~ {.haskell}
Prelude> :{
do
  l  <- [0..9]
  ps <- (\x -> [x-1,x+2]) l
  return ps
:}
[-1,2,0,3,1,4,2,5,3,6,4,7,5,8,6,9,7,10,8,11]
~~~~

First, the list is bound to *l*, then our predecessor/successor function
is applied to *l*. Since we are using this function in the context of
the list monad, the function is be applied to every member of *l*. The
results of these applications is concatenated.

### Note

Experimenting with list monads may give you results that may be
surprising at first sight. For instance:

~~~~ {.haskell}
Prelude> :{
do
  l <- [0..9]
  m <- [42,11]
  return m
:}
[42,11,42,11,42,11,42,11,42,11,42,11,42,11,42,11,42,11,42,11]
~~~~

Since *[42,11]* in *m <- [42,11]* does not use an argument, its
corresponding function is
`\_ ->                         [42,11]`{.function}. Since
`foldr`{.function} still traverses the list bound to *l*, the monadic
computation is equal to:

~~~~ {.haskell}
Prelude> foldr ((++) . (\_ -> [42,11])) [] [0..9]
[42,11,42,11,42,11,42,11,42,11,42,11,42,11,42,11,42,11,42,11]
~~~~

We can also extract bigrams using the list monad. Given a list of tails,
we could extract the first two words of each tail using
`take`{.function}:

~~~~ {.haskell}
Prelude> import Data.List
Prelude Data.List> let sent = ["Colorless", "green", "ideas", "sleep", "furiously"]
Prelude Data.List> :{
do
  t <- tails sent
  l <- take 2 t
  return l
:}
["Colorless","green","green","ideas","ideas","sleep","sleep","furiously","furiously"]
~~~~

That's close. However, since the list monad concatenates the results of
every *take 2 t* expression, we cannot directly identify the n-grams
anymore. This is easily remedied by wrapping the result of
`take`{.function} in a list:

~~~~ {.haskell}
Prelude Data.List> :{
do
  t <- tails sent
  l <- [take 2 t]
  return l
:}
[["Colorless","green"],["green","ideas"],["ideas","sleep"],["sleep","furiously"],["furiously"],[]]
~~~~

Now we get the n-grams nicely as a list. However, as in previous
definitions of `ngrams`{.function} we have to exclude lists that do not
have the requested number of elements. We could, as we did previously,
filter out these members using `filter`{.function}:

~~~~ {.haskell}
Prelude Data.List> :{
filter ((==) 2 . length) $ do
  t <- tails sent
  l <- [take 2 t]
  return l
:}
[["Colorless","green"],["green","ideas"],["ideas","sleep"],["sleep","furiously"]]
~~~~

But that would not be a very monadic way to perform this task. It would
be nice if we could just choose elements to our liking. Such a (monadic)
choice function exists, namely `Control.Monad.guard`{.function}:

~~~~ {.haskell}
Prelude Data.List> import Control.Monad
Prelude Data.List Control.Monad> :type guard
guard :: MonadPlus m => Bool -> m ()
~~~~

`guard`{.function} is a function that takes a boolean, and returns
something that is a `MonadPlus`{.classname}. Whoa! For now, accept that
the list type belongs to the `MonadPlus`{.classname} type class (after
importing *Control.Monad*). Instead of going into the working of
`MonadPlus`{.classname} now, we will perform a behavioral study of
`guard`{.function}:

~~~~ {.haskell}
Prelude Data.List Control.Monad> :{
do
  l <- [0..9]
  guard (even l)
  return l
:}
[0,2,4,6,8]
~~~~

Funky huh? We used `guard`{.function} to enumerate just those numbers
from *[0..9]* that are even. Of course, we could as well use
`guard`{.function} in our bigram extraction to filter lists that are not
of a certain length:

~~~~ {.haskell}
Prelude Data.List Control.Monad> :{
do
  t <- tails sent
  l <- [take 2 t]
  guard (length l == 2)
  return l
:}
[["Colorless","green"],["green","ideas"],["ideas","sleep"],["sleep","furiously"]]
~~~~

Ain't that beautiful? We applied a guard to pick just those elements
that are of length *2*, or as you might as well say, we put a constraint
on the list requiring elements to be of length *2*. We can easily
transform this expression to a function, by making the n-gram length and
the list arguments of that function:

~~~~ {.programlisting}
ngrams'' :: Int -> [a] -> [[a]]
ngrams'' n l = do
  t <- tails l
  l <- [take n t]
  guard (length l == n)
  return l 
~~~~

As you can conclude from the previous sections, there is often more than
one way to implement a function. In practice you will want to pick a
declaration that is readable and performant. In this case, we think that
the declarative definition of `ngrams`{.function} is the most
preferable.

### 3.5.3. Exercises

1.  Rewrite the `skipBigram`{.function} function discussed in [Section
    3.2.1, “Exercises”](chap-ngrams.xhtml#chap-ngrams-bigrams-exercises)
    without explicit recursion, either by defining it more declaratively
    or using the list monad. Hint: make use of the
    `Data.List.zip`{.function} function.

## 3.6. Lazy and strict evaluation

You may have noticed that something curious goes on in Haskell. For
instance, consider the following GHCi session:

~~~~ {.haskell}
Prelude> take 10 $ [0..]
[0,1,2,3,4,5,6,7,8,9]
~~~~

The expression `[0..`{.function} is the list of numbers from zero to
infinity. Obviously, it is impossible to store an infinite list in
finite memory. Haskell does not apply some simple trick, since it also
works in less trivial cases. For instance:

~~~~ {.haskell}
Prelude> take 10 $ filter even [0..]
[0,2,4,6,8,10,12,14,16,18]
~~~~

This also works for your own predicates:

~~~~ {.haskell}
Prelude> let infinite n = n : infinite (n + 1)
Prelude> take 3 $ infinite 0
[0,1,2,3]
~~~~

In most other programming languages, this computation will never
terminate, since it will go into an infinite recursion. Haskell,
however, won't. The reason is that Haskell uses lazy evaluation - an
expression is only evaluated when necessary. For instance, taking three
elements from `infinite`{.function} results in the following
evaluations:

~~~~ {.programlisting}
infinite 0
0 : infinite 1
0 : (1 : infinite 2)
0 : (1 : (2 : infinite 3))
0 : (1 : (2 : (3 : infinite 4)))
~~~~

Once `take`{.function} has consumed enough elements from
`infinite`{.function}, the tail of the list is the expression
`infinite 4`{.function}. Since `take`{.function} does not need more
elements, the tail is never evaluated. Lazy evaluation allows you to do
clever tricks, such as defining infinite lists. The downside is that it
is often hard to predict when an expression is evaluated, and what
effect that has on performance of a program.

Todo: lazy evaluation and folds.

## 3.7. Suffix arrays

In this chapter, we have seen how you could extract an n-gram of a given
n from a list of words, characters, groceries, or whatever you desire.
You can also store n-gram frequencies in a Map, to build applications
that quickly need the frequency (or probability) of an n-gram in a
corpus. What if you would encounter an application where you need access
to n-grams of any length? Any! From unigrams to 'almost the length of
your corpus'-grams. Obviously, if your corpus contains m elements,
storing frequencies of all 1..m-grams would make your program a memory
hog.

Fortunately, it turns out that there is a simple and smart trick to do
this, using a data structure called suffix arrays. First, we start with
the corpus, and a parallel list or array where each element contains an
index that can be seen as a pointer into the corpus. The left side of
figure [Figure 3.1, “Constructing a suffix
array”](chap-ngrams.xhtml#fig-suffixarray) shows the initial state for
the phrase "to be or not to be". We then sort the array of indices by
comparing the elements they point to. For instance, we could compare the
element with index 2 ("or") and the element with index 3 ("not"). Since
"not" is lexicographically ordered before "or", the list of indices
should be sorted such that the element holding index 3 comes before 2.
When two indices point to equal elements, e.g. 0 and 4 ("to"), we move
on to the element that succeed both instances of "to", respectively "be"
and "be". And we continue such comparisons recursively, until we find
out that one n-gram is lexicographically sorted before the other (in
this case, 4 should come before 0, since "to be" is lexicographically
sorted before "to be or". The right side of figure [Figure 3.1,
“Constructing a suffix array”](chap-ngrams.xhtml#fig-suffixarray) shows
how the indices will be sorted after applying this sorting methodology.

**Figure 3.1. Constructing a suffix array**

  --------------------------------------------------------------------
  ![Constructing a suffix array](../images/suffixarray-unsorted.svg)
  --------------------------------------------------------------------

Unsorted indices

  ------------------------------------------------------------------
  ![Constructing a suffix array](../images/suffixarray-sorted.svg)
  ------------------------------------------------------------------

Sorted indices

\

After sorting the list of indices in this manner, the index list
represents an ordered list of n-grams within the corpus. The length of
the n-gram does not matter, since elements and their suffixes were
compared until one element could be sorted lexicographically before the
other. This ordering also implies that we can use a binary search to
check whether an n-gram occurred in the corpus, and if so, how often.
But more on that later...

Of course, as a working programmer you can't wait to fire up your text
editor to implement suffix arrays. It turns out to be simpler than you
might expect. But, we need to introduce another data type first, the
vector. It is a data type that is comparable to arrays in other
programming languages. Vectors allow for random access to array
elements. So, if you want to access the n-th element of a vector, it can
be accessed directly, rather than first traversing the n-1 preceding
elements as in a list. Vectors are provided in Haskell as a part of the
vector package that can be installed using **cabal**. We can construct a
Vector from a list and convert a Vector to a list:

~~~~ {.haskell}
Prelude> Data.Vector.fromList ["to","or","not","to","be"]
fromList ["to","or","not","to","be"] :: Data.Vector.Vector
Prelude> Data.Vector.toList $ Data.Vector.fromList ["to","or","not","to","be"]
["to","or","not","to","be"]
~~~~

The `(!)`{.function} function is used to access an element:

~~~~ {.haskell}
Prelude> (Data.Vector.fromList ["to","or","not","to","be"]) Data.Vector.! 3
"to"
~~~~

There's also a safe access function, `(!?)`{.function}, that wraps the
element in a Maybe. Nothing is returned when you use an index that is
'outside' the vector:

~~~~ {.haskell}
Prelude> (Data.Vector.fromList ["to","or","not","to","be"]) Data.Vector.! 20
"*** Exception: ./Data/Vector/Generic.hs:222 ((!)): index out of bounds (20,5)
Prelude> (Data.Vector.fromList ["to","or","not","to","be"]) Data.Vector.!? 20
Nothing
Prelude> (Data.Vector.fromList ["to","or","not","to","be"]) Data.Vector.!? 3
Just "to"
~~~~

That enough for now. The primary reason why Vector is a useful type
here, is because we want random access to the corpus during the
construction of the suffix array. After construction, it is also useful
for most tasks to be able to access the indices randomly. Alright, first
we create a data type for the suffix array:

~~~~ {.programlisting}
import qualified Data.Vector as V

data SuffixArray a = SuffixArray (V.Vector a) (V.Vector Int)
                     deriving Show
~~~~

It says exactly what we saw in the figure above: a suffix array consists
of a data vector (in our case a corpus) and a vector of indices,
respectively V.Vector a and V.Vector Int. Ideally, we would like to
construct a suffix array from a list. However, to do this, we need a
sorting function. The Data.List module contains the `sortBy`{.function}
function that sorts a list according to some ordering function:

~~~~ {.haskell}
*Main> :type Data.List.sortBy
Data.List.sortBy :: (a -> a -> Ordering) -> [a] -> [a]
~~~~

So, it takes a comparison function that should compare two elements, and
that returns Ordering. Ordering is a data type that specifies... order.
There are three constructors: LT, EQ, andGT, these constructors indicate
respectively that the first argument is less than, equal to, or greater
than the second argument.

We will use `sortBy`{.function} to sort the list of indices. Since the
ordering of the indices is determined by elements of the data array, to
which the indices refer, the comparison function that we provide for
sorting the index array requires access to the data array. So, our
function will compare (sub)vectors, indicated by their indices. This
will work, since the Data.Vector data type is of the Ord type class,
meaning that the operators necessary for comparisons are provided. Our
comparison function can be written like this:

~~~~ {.programlisting}
saCompare :: Ord a => (V.Vector a -> V.Vector a -> Ordering) ->
             V.Vector a -> Int -> Int -> Ordering
saCompare cmp d a b = cmp (V.drop a d) (V.drop b d)
~~~~

To allow a user of our function to impose their own sorting order (maybe
the want to make a reversibly offered suffix array), we
`saCompare`{.function} requires a comparison function as its first
argument. The second argument is the data vector, and the final two
arguments are the indices to be compared. We can get the subvectors
represented by the two indices by using the
`Data.Vector.drop`{.function} function. Suppose, if we want the element
at index two, we can just drop the first two arguments, since we start
counting at zero. We then use the provided comparison function to
compare the two subvectors.

Now we can create the function that actually creates a suffix array:

~~~~ {.programlisting}
import qualified Data.List as L

suffixArrayBy :: Ord a => (V.Vector a -> V.Vector a -> Ordering) ->
                 V.Vector a -> SuffixArray a
suffixArrayBy cmp d = SuffixArray d (V.fromList srtIndex)
    where uppBound = V.length d - 1
          usrtIndex = [0..uppBound]
          srtIndex = L.sortBy (saCompare cmp d) usrtIndex
~~~~

This function is fairly simple, first we create the unsorted list of
indices and bind it to `usrtIndex`{.varname}. We construct this list by
using a range. A range contains the indicated lower bound and upper
bound, and all integers in between;

~~~~ {.haskell}
*Main> [0..9]
[0,1,2,3,4,5,6,7,8,9,10]
~~~~

We retrieve the upper bound using the `Data.Vector.length`{.function}
function by subtracting one, since we are counting from zero. We then
obtain the sorted index (`srtIndex`{.varname}) by using the
`Data.List.sortBy`{.function} function. This function takes a comparison
function as its first argument and a list as its second argument:

~~~~ {.haskell}
*Main> :type Data.List.sortBy
Data.List.sortBy :: (a -> a -> Ordering) -> [a] -> [a]
~~~~

We can just plug in our `saCompare`{.function} function, which we pass a
comparison function, and the data vector. Finally, we use the
SuffixArray constructor to construct a SuffixArray, converting the list
of indices to a vector. For convenience, we can also add a function that
uses Haskell's `compare`{.function} function that uses the default
sorting order that is imposed by the Ord typeclass:

~~~~ {.programlisting}
suffixArray :: Ord a => V.Vector a -> SuffixArray a
suffixArray = suffixArrayBy compare
~~~~

Neat! But as you have noticed by now, every serious data type has
`fromList`{.function} and `toList`{.function} functions, so ours should
have those as well. `fromList`{.function} is really simple; we can
already construct a suffix array from a Vector using the
`suffixArray`{.function} function. So, we just need to convert a list to
a Vector, and pass it to `suffixArray`{.function}:

~~~~ {.programlisting}
fromList :: Ord a => [a] -> SuffixArray a
fromList = suffixArray . V.fromList
~~~~

Easy huh? The `toList`{.function} is a bit more involved. First we have
to decide what it should actually return. Providing the data vector as a
list is not very useful, it's probably what someone started with.
Returning a list of indices is more useful, but then we shift the burden
off retrieving the n-grams that every index represents to the user of
our suffix array. The most useful thing would be to return a list of all
n-grams (of any length). So, for the phrase "to be or not to be", we
want to return the following elements:

-   ["be"]

-   ["be","or","not","to","be"]

-   ["not","to","be"]

-   ["or","not","to","be"]

-   ["to","be"]

-   ["to","be","or","not","to","be"]

To achieve this, we need to extract the subvector for each index, in the
order that the sorted vector of indices indicates. We can then convert
each subvector to a list. We can use `Data.Vector.foldr`{.function}
function to traverse the vector, constructing a list for each index. We
will accumulate these lists in (yet another) list. Please welcome
`toList`{.function}:

~~~~ {.programlisting}
toList :: SuffixArray a -> [[a]]
toList (SuffixArray d i) = V.foldr vecAt [] i
    where vecAt idx l = V.toList (V.drop idx d) : l
~~~~

The `vecAt`{.function} function extracts a subvector starting at index
`idx`{.varname}, converts it to a list. We form a new list, with the
accumulator as the tail, and the newly constructed 'subvector list' as
the head. We use `foldr`{.function} to ensure that the list that is
being constructed is in the correct order - since the accumulator
becomes the tail, a `foldl`{.function} would make the first subarray the
last in the list. Time to play with our new data type a bit:

~~~~ {.haskell}
*Main> toList $ fromList ["to","be","or","not","to","be"]
[["be"],
["be","or","not","to","be"],
["not","to","be"],
["or","not","to","be"],
["to","be"],
["to","be","or","not","to","be"]]
~~~~

Excellent, just as we want it: we get an ordered list of all n-grams in
the corpus, for the maximum possible n. We can use this function to
extract all bigrams:

~~~~ {.haskell}
*Main> filter ((== 2) . length) $ map (take 2) $ toList $ \
  fromList ["to","be","or","not","to","be"]
~~~~

We extract the first two elements of each n-gram. This also gives us one
unigram (the last token of the corpus), so we also have to filter the
list for lists that contain two elements.

After some celebrations and a cup of tea, it is time to use suffix
arrays to find the frequency of a word. To do this, we use a binary
search. For quick accessibility, we create a function comparable to the
`toList`{.function} method, but returning a Vector of Vector, rather
than a list of list:

~~~~ {.programlisting}
elems :: SuffixArray a -> V.Vector (V.Vector a)
elems (SuffixArray d i) = V.map vecAt i
    where vecAt idx = V.drop idx d
~~~~

Note that we can use `Data.Vector.map`{.function} in this case, since it
maps a function over all elements of vector, returning a vector:

~~~~ {.haskell}
*Main> :type Data.Vector.map
Data.Vector.map :: (a -> b) -> V.Vector a -> V.Vector b
~~~~

Note: if you have a computer science background, you might want to skip
the next paragraphs.

To be able to count the number of occurrences of an n-gram in the suffix
array, we need to locate the n-gram in the suffix array first. We could
just traverse the array from beginning to the end, comparing each
element to the n-gram that we are looking for. However, this is not very
inefficient. During every search step, we exclude just one element. For
instance, if we have the numbers 0 to 9 and have to find the location of
the number 7, the first search step would just exclude the number 0,
leaving eight potential candidates ([Figure 3.2, “Linear search
step”](chap-ngrams.xhtml#fig-linear-search-step)).

**Figure 3.2. Linear search step**

  ----------------------------------------------------
  ![Linear search step](../images/linear-search.svg)
  ----------------------------------------------------

\

However, if we know that the vector of numbers is sorted, we can devise
a more intelligent strategy. As a child, you probably played number
guessing games. In one variant of the game, you would guess a number,
and the person knowing the correct number would shout "smaller",
"larger" or "correct". Being a smart kid, you would probably not start
guessing at 1 if you had to guess a number between 1 and 100. Usually,
you'd start somewhere halfway the range (say 50), and continue halfway
the 1..50 or 51..100 range if the number was smaller or greater than 50.

The same trick can be applied when searching a sorted vector. If you
compare a value to the element in the middle, you remove cut half of the
search space (if initial guess was not correct). This procedure is
called a binary search. For instance, [Figure 3.3, “Binary search
step”](chap-ngrams.xhtml#fig-binary-search) shows the first search step
when applying a binary search to the example in [Figure 3.2, “Linear
search step”](chap-ngrams.xhtml#fig-linear-search-step).

**Figure 3.3. Binary search step**

  ----------------------------------------------------
  ![Binary search step](../images/binary-search.svg)
  ----------------------------------------------------

\

The performance of binary search compared to linear search should not be
underestimated: the time of a linear search grows linearly with the
number of elements (yes, we like pointing out the obvious), while time
of a binary search grows logarithmically. Suppose that we have a sorted
vector of 1048576 elements, a linear search would at most take 1048576
steps, while a binary search takes at most 20 steps. Pretty impressive
right?

On to our binary search function. `binarySearchByBounded`{.function}
finds the index of an element in a Vector, wrapped in Maybe. If the
element has multiple occurrences in the Vector, just one index is
returned. If the element is not in the Vector, Nothing is returned.

~~~~ {.programlisting}
binarySearchByBounded :: (Ord a) => (a -> a -> Ordering) -> V.Vector a ->
                         a -> Int -> Int -> Maybe Int
binarySearchByBounded cmp v e lower upper
    | V.null v      = Nothing
    | upper < lower = Nothing
    | otherwise     = case cmp e (v V.! middle) of
                        LT -> binarySearchByBounded cmp v e lower (middle - 1)
                        EQ -> Just middle
                        GT -> binarySearchByBounded cmp v e (middle + 1) upper
    where middle    = (lower + upper) `div` 2
~~~~

`binarySearchByBounded`{.function} takes a host of arguments: a
comparison function, the (sorted) vector (`v`{.varname}, the element to
search for (`e`{.varname}), and lower (`lower`{.varname}) and upper
bound (`upper`{.varname}) indices of the search space. The function
works just like we described above. First we have to find the middle of
the current search space, we do this by averaging the upper and lower
bounds and binding it to `middle`{.varname}. We then compare the element
at index `middle`{.varname} in the vector to `e`{.varname} . If both are
equal (EQ), then we are done searching, and return `Just middle`{.code}
as the index. If `e`{.varname} is smaller than (LT) the current element,
we search in the lower half of the search space
(`lower`{.varname}..`middle`{.varname}-1). If `e`{.varname} is greater
than (GT) the current element, we search in the upper half of the search
space (`middle`{.varname}+1..`upper`{.varname}). If `e`{.varname} does
not occur in the search space, `upper`{.varname} will become smaller
than `lower`{.varname} when we have exhausted the search space.

Let's define two convenience functions to make binary searches a bit
simpler:

~~~~ {.programlisting}
binarySearchBounded :: (Ord a) => V.Vector a -> a -> Int -> Int -> Maybe Int
binarySearchBounded = binarySearchByBounded compare

binarySearchBy :: (Ord a) => (a -> a -> Ordering) -> V.Vector a -> a ->
                  Maybe Int
binarySearchBy cmp v n = binarySearchByBounded cmp v n 0 (V.length v - 1)

binarySearch :: (Ord a) => V.Vector a -> a -> Maybe Int
binarySearch v e = binarySearchBounded v e 0 (V.length v - 1)
~~~~

`binarySearchBounded`{.function} calls
`binarySearchByBounded`{.function}, using Haskell's standard compare
function. `binarySearchBy`{.function} calls
`binarySearchByBounded`{.function}, binding the upper and lower bounds
to the lowest index of the array (0) and the highest (the size of the
Vector minus one). Finally, `binarySearch`{.function} combines the
functionality of `binarySearchBounded`{.function} and
`binarySearchBy`{.function}, Let's give the binary search functionality
a try:

~~~~ {.haskell}
*Main> binarySearch (V.fromList [1,2,3,5,7,9]) 9
Just 1
*Main> binarySearch (V.fromList [1,2,3,5,7,9]) 10
Just 5
*Main> binarySearch (V.fromList [1,2,3,5,7,9]) 10
~~~~

Great! Let's make a step in between, returning to suffix arrays. Say
that you would want to write a `contains`{.function} function that
returns True if an n-gram is in the suffix array, or False otherwise.
Easy right? Your first attempt may be something like:

~~~~ {.haskell}
*Main> let corpus = ["to","be","or","not","to","be"]
*Main> binarySearch (elems $ fromList corpus) $ Data.Vector.fromList ["or","not", "to", "be"]
Just 3
~~~~

Nice, right? But try this example:

~~~~ {.haskell}
*Main> binarySearch (elems $ fromList corpus) $ Data.Vector.fromList ["or","not"]
Nothing
~~~~

You can almost hear the commentator of Roger Wilco and the Time Rippers
in the background, right? Right! Of course, the element that we are
looking for contains the n-gram of the maximum length ("or not to be").
That is why the first example worked, while the second did not. So, we
have to apply the binary search to something that only contains bigrams
in this case:

~~~~ {.haskell}
*Main> :{
*Main| binarySearch
*Main|   (Data.Vector.map (Data.Vector.take 2) $ elems $ fromList corpus) $
*Main|   Data.Vector.fromList ["or","not"]
*Main| :}
Just 3
~~~~

That did the trick. Writing the contains function is now simple:

~~~~ {.programlisting}
contains :: Ord a => SuffixArray a -> V.Vector a -> Bool
contains s e = case binarySearch (restrict eLen s) e of
                 Just _  -> True
                 Nothing -> False
    where eLen = V.length e
          restrict len = V.map (V.take len) . elems
~~~~

To find the frequency of an element in a Vector, we have to do a bit
more than locating one instance of that element. One first intuition
could be to find the element, and scan upwards and downwards to find how
many instances of the element there are in the Vector. However, there
could be millions of such elements. Doing a linear search is, again, not
very efficient. So, we should apply a binary search, but not just to
find one instance of the element, but specifically the first and the
last.

Such search functions are very comparable to the
`binarySearchByBounds`{.function} function that we wrote earlier. Let's
start with finding the first index in the Vector where a specified
element occurs. Suppose that we do a binary search again: if the element
in the middle of our search space is greater than the element, we want
to continue searching in the lower half of the search space. If the
element in the middle is smaller than the element, we want to continue
searching in the upper half of the search space. If the middle is
however equal to the element, we do not stop searching, but continue
searching the lower half. We still keep the element that was equal in
the search space, since it may have been the only instance of that
element. This gives us the following `lowerBoundByBounds`{.function}
function and corresponding helpers:

~~~~ {.programlisting}
lowerBoundByBounds :: Ord a => (a -> a -> Ordering) -> V.Vector a -> a ->
                      Int -> Int -> Maybe Int
lowerBoundByBounds cmp v e lower upper
    | V.null v = Nothing
    | upper == lower = case cmp e (v V.! lower) of
                         EQ -> Just lower
                         _  -> Nothing
    | otherwise = case cmp e (v V.! middle) of
                    GT -> lowerBoundByBounds cmp v e (middle + 1) upper
                    _  -> lowerBoundByBounds cmp v e lower middle
    where middle = (lower + upper) `div` 2

lowerBoundBounds :: Ord a => V.Vector a -> a -> Int -> Int -> Maybe Int
lowerBoundBounds = lowerBoundByBounds compare

lowerBoundBy :: Ord a => (a -> a -> Ordering) -> V.Vector a -> a -> Maybe Int
lowerBoundBy cmp v e = lowerBoundByBounds cmp v e 0 (V.length v - 1)

lowerBound :: Ord a => V.Vector a -> a -> Maybe Int
lowerBound = lowerBoundBy compare
~~~~

Searching the last index in the Vector where the element occurs, follows
a comparable procedure. We search as normal, however if the element is
equal to the middle we search the upper half of the search space
including the element that we found to be equal. Give the floor to
`upperBoundByBounds`{.function} and helpers:

~~~~ {.programlisting}
upperBoundByBounds :: Ord a => (a -> a -> Ordering) -> V.Vector a -> a ->
                      Int -> Int -> Maybe Int
upperBoundByBounds cmp v e lower upper
    | V.null v       = Nothing
    | upper <= lower = case cmp e (v V.! lower) of
                         EQ -> Just lower
                         _  -> Nothing
    | otherwise      = case cmp e (v V.! middle) of
                         LT -> upperBoundByBounds cmp v e lower (middle - 1)
                         _  -> upperBoundByBounds cmp v e middle upper
    where middle     = ((lower + upper) `div` 2) + 1

upperBoundBounds :: Ord a => V.Vector a -> a -> Int -> Int -> Maybe Int
upperBoundBounds = upperBoundByBounds compare

upperBoundBy :: Ord a => (a -> a -> Ordering) -> V.Vector a -> a -> Maybe Int
upperBoundBy cmp v e = upperBoundByBounds cmp v e 0 (V.length v - 1)

upperBound :: Ord a => V.Vector a -> a -> Maybe Int
upperBound = upperBoundBy compare
~~~~

Note that we add one to the middle in this case. This is to avoid
landing in an infinite recursion when `middle`{.varname} is
`lower`{.varname} plus one, and the element is larger than or equal to
the element at `middle`{.varname}. Under those circumstances,
`lower`{.varname} and `upper`{.varname} would be unchanged in the next
recursion.

Great. I guess you will now be able to write that function in terms of
`lowerBoundByBounds`{.function} and `upperBoundByBounds`{.function}:

~~~~ {.programlisting}
frequencyByBounds :: Ord a => (a -> a -> Ordering) -> V.Vector a -> a ->
                     Int -> Int -> Maybe Int
frequencyByBounds cmp v e lower upper = do
  lower <- lowerBoundByBounds cmp v e lower upper
  upper <- upperBoundByBounds cmp v e lower upper
  return $ upper - lower + 1

frequencyBy :: Ord a => (a -> a -> Ordering) -> V.Vector a -> a ->
               Maybe Int
frequencyBy cmp v e = frequencyByBounds cmp v e 0 (V.length v - 1)

frequencyBounds :: Ord a => V.Vector a -> a -> Int -> Int -> Maybe Int
frequencyBounds = frequencyByBounds compare

frequency :: Ord a => V.Vector a -> a -> Maybe Int
frequency = frequencyBy compare
~~~~

This function works as expected:

~~~~ {.haskell}
*Main> frequency (V.fromList [1,3,3,4,7,7,7,10]) 7
Just 3
*Main> frequency (V.fromList [1,3,3,4,7,7,7,10]) 5
Nothing
~~~~

We can use this with our suffix array now:

~~~~ {.haskell}
*Main> let corpus = ["to","be","or","not","to","be"]
*Main> let sa = fromList corpus
*Main> containsWithFreq sa $ Data.Vector.fromList ["not"]
Just 2
*Main> containsWithFreq sa $ Data.Vector.fromList ["not"]
Just 1
*Main> containsWithFreq sa $ Data.Vector.fromList ["jazz","is","not","dead"]
Nothing
*Main> containsWithFreq sa $ Data.Vector.fromList ["it","just","smells","funny"]
Nothing
~~~~

### 3.7.1. Exercises

1.  Write a function `mostFrequentNgram`{.function} with the following
    type signature:

~~~~ {.programlisting}
mostFrequentNgram :: Ord a => SuffixArray a -> Int -> Maybe (V.Vector a, Int)
~~~~

    This function extracts the most frequent n-gram from a suffix array,
    where the suffix array and n are given as arguments. The function
    should continue a pair of the n-gram and the frequency as a typle
    wrapped in Maybe. If no n-gram could be extracted (for instance,
    because the suffix array contains to few elements), return Nothing.

2.  Use `mostFrequentNgram`{.function} to find the most frequent bigram
    and trigram in the Brown corpus.

3.  frequencyByBounds is not as efficient as it could be: it performs a
    search of the full Vector twice. A more efficient solution would be
    to narrow down the search space until the first match is found, and
    then using `lowerBoundByBounds`{.function} and
    `upperBoundByBounds`{.function} to search the lower and upper half
    of the search space. Modify `frequencyByBounds`{.function} to use
    this methodology.

## 3.8. Markov models

At the beginning of this chapter we mentioned that n-grams can be
exploited to model language. While they may not be so apt as
computational grammars, n-grams do encode some syntax albeit local. For
instance, consider the following to phrases:

-   the plan was

-   \* plan the was

The first phrase is clearly grammatical, while the second is not. We
could neatly encode this using a syntax rule, but we could also count
how often both combinations of words occur in a large text corpus. The
first phrase is likely to occur a few times, while the second phrase is
not likely to occur. Or more formally, the probability that we encounter
*this plan was* occurs in a random text is higher than the probability
that *plan this was* occurs:

**Equation 3.3.**

p(the plan was) \> p(plan the was)

\

Of course, we could also try to find the most grammatical of two
sentences by comparing the probabilities of the sentences. So, if we
have a sentence consisting of the words w~0..n~ and a sentence
consisting of the words v~0..m~ that both aim to express the same
meaning and the following is true:

**Equation 3.4.**

p ( w 0 .. n ) \> p ( v 0 .. m )

\

We could conclude that the use of w~0..n~ is preferred over v~0..m~,
since w~0..n~ is either more grammatical or more fluent. So, how do we
estimate the probability of such a sentence? Good question, at first
sight it seems pretty easy. We simply count how often a sentence occurs
in a text corpus, and divide it by the total number of sentences in a
corpus:

**Equation 3.5. Estimating the probability of a sentence**

p( w 0 .. n ) = C( w 0 .. n ) N

\

Here *C* is a counter function, and *N* is the total number of sentences
in a corpus. While this is a theoretically sound method for estimating
the probability, it does not work in practice. As ingenious as human
language is, we can construct an infinite number of grammatical
sentences. So, to be able to estimate the probability we would need an
infinite text corpus, since not every grammatical sentence will occur in
a finite corpus. Given that we only have a finite text corpus, we would
simply give a probability of zero to many perfectly grammatical
sentences. We encounter so-called *data sparseness*. This is nasty,
because it interferes with our goal to compare the quality of sentences.

Fortunately for us, some smart people have thought about this problem,
and came up with a pretty elegant solution (or \`workaround' as we
programmers like call it). To get to the solution, we have to make an
intermediate step. This intermediate step does not immediately solve our
problem, but sets the stage for the solution. We can decompose the
probability of a sentence *p(w~0..n~)* into a series of conditional
probabilities:

**Equation 3.6. The probability of a sentence as a Markov chain**

p ( w 0 ‥ n ) = p ( w 0 ) p ( w 1 | w 0 ) ‥ p ( w 0 ‥ n | w 0 ‥ n - 1 )

\

Before this gets too confusing, let's write down how you would estimate
the probability of the sentence *Colorless green ideas sleep furiously*
in this manner: *p(Colorless) p(green|Colorless) p(ideas|Colorless
green) p(sleep|Colorless green ideas) p(furiously|Colorless green ideas
sleep)*.

Simple huh? Now, how do we estimate such a conditional probability?
Formally, this is estimated in the following manner:

**Equation 3.7.**

p ( w n | w 0 ‥ n - 1 ) = C ( w 0 ‥ n ) C ( w 0 ‥ n - 1 )

\

That is all nice and dandy, but as you may already see, this does not
solve our problem with data sparseness. For if we want to estimate
*p(furiously|Colorless green ideas sleep)*, we need counts of *Colorless
green ideas sleep* and *Colorless green ideas sleep furiously*. Even if
we decompose the probability of a sentence into conditional
probabilities, we need counts for the complete sentence.

However, if we look at the conditional probability of a word, the
following often holds:

**Equation 3.8. Approximation using the Markov assumption**

p ( w n | w 0 ‥ n - 1 ) ≈ p ( w n | w n - 1 )

\

More formally, this is a process with the *Markov property*: prediction
of the next state (word) is only dependent on the current state. Of
course, we can easily calculate our revised conditional probability:

**Equation 3.9. The conditional probability of a word using the Markov
assumption**

p ( w n | w n - 1 ) = C ( w n - 1 , n ) C ( w n - 1 )

\

That spell worked! We only need counts of... unigrams (1-grams) and
bigrams to estimate the conditional probability of each word. This is a
*bigram language model*, which we can use to estimate to probability of
a sentence:

**Equation 3.10. The probability of a sentence using a bigram model**

p( w 0 .. n ) = ∏ i = 0 n p ( w n | w n - 1 )

\

In practice it turns out that knowledge of previous states can help a
bit in estimating the conditional probability of a word. However, if we
increase the context too much, we run into the same data sparseness
problems that we solved by drastically cutting the context. The
consensus is that for most applications a trigram language model
provides a good trade-off between data availability and estimator
quality.

### 3.8.1. Implementation

The implementation of a bigram Markov model in Haskell should now be
trivial. If we have a frequency map of unigrams and bigrams of the type
(Ord a, Integral n) =\> Map [a] n, we could write a function that
calculates p ( w n | w n - 1 ) , or more generally p ( state n | state n
- 1 ) :

~~~~ {.programlisting}
import qualified Data.Map as M
import Data.Maybe (fromMaybe)

pTransition :: (Ord a, Integral n, Fractional f) =>
  M.Map [a] n -> a -> a -> f
pTransition ngramFreqs state nextState = fromMaybe 0.0 $ do
  stateFreq <- M.lookup [state] ngramFreqs
  transFreq <- M.lookup [state, nextState] ngramFreqs
  return $ (fromIntegral transFreq) / (fromIntegral stateFreq)
~~~~

Now we write a function that extracts all bigrams, calculates the
transition probabilities and takes the product of the transition
probabilities:

~~~~ {.programlisting}
pMarkov :: (Ord a, Integral n, Fractional f) =>
  M.Map [a] n -> [a] -> f
pMarkov ngramFreqs =
  product . map (\[s1,s2] -> pTransition ngramFreqs s1 s2) . ngrams 2
~~~~

This function is straightforward, except perhaps the
`product`{.function} function. `product`{.function} calculates the
product of a list:

~~~~ {.haskell}
Prelude> :type product
product :: Num a => [a] -> a
Prelude> product [1,2,3]
6
~~~~

* * * * *

  -------------------------- --------------------- -----------------------------------------------
  [Prev](chap-words.xhtml)                         [Next](chap-similarity.xhtml)
  Chapter 2. Words           [Home](index.xhtml)   Chapter 4. Distance and similarity (proposed)
  -------------------------- --------------------- -----------------------------------------------

