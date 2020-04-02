function processResult(result, error, output) {
   if (result[0] === 1) {
      error.innerText = result[1];
      output.innerText = "";
   } else {
      error.innerText = "";
      output.innerText = result[1];
   }
}

function processLocal(input, format, output, error) {
   let result = apidsl.parse("input.api.h", input);
   if (result[0] === 0) {
      if (format === "haskell") {
         result = apidsl.haskell("MyAPI", result[1]);
      } else {
         result = apidsl[format](result[1]);
      }
   }

   processResult(result, error, output);
}

function processRemote(input, format, output, error) {
   const apiUrl = "https://apidsl2.herokuapp.com";
   fetch(apiUrl + "/parse", {
      method: "POST",
      body: JSON.stringify(["Request", input])
   }).then((data) => data.json()).then((result) => {
      if (result[0] === 0) {
         fetch(apiUrl + "/" + format, {
            method: "POST",
            body: JSON.stringify(["Request", result[1]])
         }).then((data) => data.json()).then((result) => {
            processResult(result, error, output);
         });
      } else {
         processResult(result, error, output);
      }
   });
}

function exceptionType(err) {
   if (err instanceof Array) {
      if (err[1] instanceof Object && "c" in err[1]) {
         return err[1].c;
      }
   }
   return null;
}

function isStackOverflow(err) {
   return exceptionType(err) === "Stack_overflow" ||
      (exceptionType(err) === "Js_of_ocaml__Js.Error" &&
       err[2].includes("Maximum call stack size exceeded"));
}

function process() {
   let error = document.getElementById("error");
   let input = document.getElementById("input").value;
   let output = document.getElementById("output");
   let format = document.querySelector("input[name='format']:checked").value;

   try {
      processLocal(input, format, output, error);
   } catch (err) {
      if (isStackOverflow(err)) {
         processRemote(input, format, output, error);
      } else {
         console.log("Unhandled exception ", err);
      }
   }
}

function load(snippet) {
   const snippets = {
   "simple": "static int main();",
   "comment":
`/**
 * The main function.
 */
static int main();`,
   "namespace":
`namespace foo {
  /**
   * This is $main.
   */
  static int32_t main();
}`,
   "large":
`class foo {
  /**
   * The "this" type for all non-static functions.
   */
  struct this;

  /**
   * This is $main.
   */
  int32_t main();

  namespace bar {
    uint32_t blep();
  }

  uint8_t some_property { get(); set(); }
}`
   };

   const fileUrl = "https://raw.githubusercontent.com/TokTok/c-toxcore/master/toxcore/tox.api.h";

   let input = document.getElementById("input");
   if (snippet === "tox") {
      fetch(fileUrl).then(data => data.text()).then(text => {
         input.value = text;
         process();
      });
   } else {
      input.value = snippets[snippet];
      process();
   }
}
