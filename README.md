# Rodney

Rodney is a request parser for business intelligence use cases.

This is CURRENTLY A PROOF OF CONCEPT and may not be production ready.

The end goal of Rodney is to take a block of text and try to identify *what* a user is asking for.

For example:

Send me last year's income statement.

Rodney could return an object like this:

```
{
  entity: "income statement"
  parameter: "2014-12-31"

}
```

## What's Going On Here?

Rodney is *not* a natural language parser. He's not that smart. He's rather dumb, actually.

Based on a dictionary of entities, he's just looking for some keywords in a text request. If he finds a keyword match, based on the rules for that keyword, he might do some additional parsing.

So let's say you have a dictionary (example structure, not final)

```
  entity: "income statement"
  type: "report"
  parameters: 
    period: "date"
```

Your application could then take Rodney's response and map the `parameter` attribute to the `income statement`, run it, and send the output back to the originator.


## Use Cases

* Build an e-mail based application where users can request a report or metric.
* Build a web application where a user can enter a request in a text box and have the command executed
* Build a slack bot where users can request a report


## Installation 

`npm install rodney -g`

## Running CLI

`rodney console`

