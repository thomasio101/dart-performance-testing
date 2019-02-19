@tatumizer, you referenced the wrong name....

Anyways, I'm currently working on the new version of the experiment, but I have one major issue;  
omitting the list creation by removing lists from the verbose method wouldn't provide a fair comparison between [`Function.apply`](https://api.dartlang.org/stable/2.1.1/dart-core/Function/apply.html) and the verbose method.

I have come up with a way to reduce the performance overhead from list creation, I could reduce this overhead by generating large sets containing the parameters ahead of time.

**EDIT** @tatumizer, I will extend my previous experiment, but I won't be attempting to write a new experiment, as the complexity of the experiment actually seems to increase as I try to implement your suggestions for removing overhead...