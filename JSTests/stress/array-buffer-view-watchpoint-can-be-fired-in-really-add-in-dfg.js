//@ runDefault("--jitPolicyScale=0")

function xxx() {
  const a = {};
  Object.defineProperty(a, 0, { get: foo });
  a.length = 80000000;
  function foo() {
    new Uint8Array(a);
  }
  new Promise(foo);
  for (let i = 0; i < 10000000; i++)
    new ArrayBuffer(1000)
}

new Int8Array();

try {
  xxx();
} catch {}

let arr1 = new Uint8Array(9);
arr1[0] = 0;
for (let i = 0; i < 1000000; ++i) {}
