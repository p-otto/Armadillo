# Hints for paper writing

## preface

Explain blockchain - relevant concepts that will be used in the paper later on
Imagine reader is general computer scientist, has no prior knowledge about blockchain

## structure

- Title
- Abstract
- Introduction
- (Preliminaries) for complicated context
- Related Work
- Main Part (2-3 Sections) + Evaluation
    - Start with intuition
    - then go into detail
- Conclusions
- (Acknowledgements)
- References


### Title

Short, catchy, descriptive
Don't worry about it, choose a working title, can improve at the end

### Abstract

Summary, not teaser
No details, simple
Help reader decide whether paper is relevant

**Important**
BPMN
how does BPMN relate to technology
what is the problem
solution

Write it once at the start, then rewrite at the end

### Introduction

Establish common ground with reader
Worth readers time?
Give some results

Write it once at the start, then rewrite at the end
use it to guide paper

**Important**
-> this structure will be expected
- Context (Topic / Terminology)
- Problem & Relevance (Problem - Costs / Current state - Gain)
- Related Work (Existing solutions / Shortcomings)
- Goals / Claims (**Contribution**, Sketch Results)
- Paper structure (The remainder of this paper is structured as follows ...)

### Related Work I

Motivate
Existing solutions:
- Summarize
- Cite / **Acknowledge** (does not cost anything, can help you)
- Shortcomings
- Relation to your work
Standard references: 
- BPMN: Weskes Book
- Blockchain: Satoshi? -> maybe too basic

Where to place related work?
if closely related to your work -> after intro
if not -> before conclusion (easier story telling)

if there is very little related work, place it into intro or discussion

### Main Part

2 - 4 Sections
- 1. Basic Understanding / Intuition (as a reader: am I interested in details?)
- 2. Evalutation
- 3. Use a continuous example to explain problem / solution
- 4. Provide details
    - **use visualizations** (architecture?) -> they like that

### Conclusion

give answers to research questions / objectives

summarize **findings**

strong statements (NOT --it may be concluded--)

"I / we" vs "this paper" -> chair uses both in a mix

### Reference List

- Up-to-date
- accessibility
- few self citations (<15%)
    - if you do it it says "we dont care what happens around us" -> comes off as arrogant

avoid
- unpublished material
- websites

Journal > Conference > Workshop > Tech Report


## Content
### Footnotes

dont use for 
- references
- parentheticals comments

use (sparsely) for
- things that can be skipped
- other documentation (companies)

### Tables

Self contained captions -> above table, not below (easier reading flow)
however captions below pictures, as pictures are read first

explanation in text
(not worth explaining -> not worth making table)

reduce lines (use `booktabs` or similar LaTeX package)

### Figures

- show data
- descriptive captions
- careful with colors (printed in grayscale)
- text readable

always refer in text, describe content (use active: in this figure it is shown vs this figure shows)
format `.pdf`

### Reasoning

- Make a claim
- support with citations, evidence, proof
- ask critical questions and address them

CLAIM because of REASON based on EVIDENCE

what causes problem?
how to fix?

desirable vs feasible vs viable

### Paragraphs

technique:
- 1. state what the paragraph is about (begin)
- 2. state what the paragraph was about (end)
- 3. fill in the rest

## Template

LNCS Template

11-14 Pages (Maxmimum ist hard boundary)
