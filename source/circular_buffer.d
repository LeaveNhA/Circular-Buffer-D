module circular;

class Buffer(X) {

  import std.exception : enforce;

private:
  X[] _buffer;
  size_t _begin, _end = 0;
  bool _empty = true;

  bool isEmpty() { return _begin == _end; }
  bool isFull() { return !_empty && _begin == _end; }
  size_t calculateCircular(size_t n) { return (n + 1) % _buffer.length; }
  X at(size_t index) { return _buffer[index]; }

public:
  this(size_t size) {
    _buffer = new X[size];
  }

  X pop() {
    enforce(!isEmpty(), "Buffer is empty");

    size_t _tempBegin = _begin;
    _begin = calculateCircular(_begin);
    _empty = isEmpty();
    return at(_tempBegin);
  }

  void push(X val) {
    enforce(!isFull(), "Buffer is full");

    _buffer[_end] = val;
    _end = calculateCircular(_end);
    _empty = false;
  }

  void clear() {
    _empty = true;
    _begin = _end = 0;
  }

  void forcePush(X val) {
    if (isFull())
      pop();

    push(val);
  }
}

unittest
{
    import std.exception : assertThrown;

    immutable int allTestsEnabled = 0;

    // Reading empty buffer should fail"
    {
        auto myBuffer = new Buffer!(int)(1UL);
        assertThrown(myBuffer.pop(), "Empty buffer should throw exception if popped!");
    }

    static if (!allTestsEnabled)
    {

        // Can read an item just written
        {
            auto myBuffer = new Buffer!(char)(1);
            myBuffer.push('1');
            assert(myBuffer.pop() == '1');
        }

        // Each item may only be read once"
        {
            auto myBuffer = new Buffer!(char)(1);
            myBuffer.push('1');
            assert(myBuffer.pop() == '1');
            assertThrown(myBuffer.pop(), "Empty buffer should throw exception if popped!");
        }

        // Items are read in the order they are written
        {
            auto myBuffer = new Buffer!(char)(2);
            myBuffer.push('1');
            myBuffer.push('2');
            assert(myBuffer.pop() == '1');
            assert(myBuffer.pop() == '2');
        }

        // Full buffer can't be written to
        {
            auto myBuffer = new Buffer!(char)(1);
            myBuffer.push('1');
            assertThrown(myBuffer.push('2'),
                    "Full buffer should throw exception if new element pushed!");
        }

        // A read frees up capacity for another write
        {
            auto myBuffer = new Buffer!(char)(1);
            myBuffer.push('1');
            assert(myBuffer.pop() == '1');
            myBuffer.push('2');
            assert(myBuffer.pop() == '2');
        }

        // Read position is maintained even across multiple writes
        {
            auto myBuffer = new Buffer!(char)(3);
            myBuffer.push('1');
            myBuffer.push('2');
            assert(myBuffer.pop() == '1');
            myBuffer.push('3');
            assert(myBuffer.pop() == '2');
            assert(myBuffer.pop() == '3');
        }

        // Items cleared out of buffer can't be read
        {
            auto myBuffer = new Buffer!(char)(1);
            myBuffer.push('1');
            myBuffer.clear();
            assertThrown(myBuffer.pop(), "Empty buffer should throw exception if popped!");
        }

        // Clear frees up capacity for another write
        {
            auto myBuffer = new Buffer!(char)(1);
            myBuffer.push('1');
            myBuffer.clear();
            myBuffer.push('2');
            assert(myBuffer.pop() == '2');
        }

        // Clear does nothing on empty buffer
        {
            auto myBuffer = new Buffer!(char)(1);
            myBuffer.clear();
            myBuffer.push('1');
            assert(myBuffer.pop() == '1');
        }

        // Overwrite acts like write on non-full buffer
        {
            auto myBuffer = new Buffer!(char)(2);
            myBuffer.push('1');
            myBuffer.forcePush('2');
            assert(myBuffer.pop() == '1');
            assert(myBuffer.pop() == '2');
        }

        // Overwrite replaces the oldest item on full buffer
        {
            auto myBuffer = new Buffer!(char)(2);
            myBuffer.push('1');
            myBuffer.push('2');
            myBuffer.forcePush('3');
            assert(myBuffer.pop() == '2');
            assert(myBuffer.pop() == '3');
        }

        // Overwrite replaces the oldest item remaining in buffer following a read
        {
            auto myBuffer = new Buffer!(char)(3);
            myBuffer.push('1');
            myBuffer.push('2');
            myBuffer.push('3');
            assert(myBuffer.pop() == '1');
            myBuffer.push('4');
            myBuffer.forcePush('5');
            assert(myBuffer.pop() == '3');
            assert(myBuffer.pop() == '4');
            assert(myBuffer.pop() == '5');
        }

        // Initial clear does not affect wrapping around
        {
            auto myBuffer = new Buffer!(char)(2);
            myBuffer.clear();
            myBuffer.push('1');
            myBuffer.push('2');
            myBuffer.forcePush('3');
            myBuffer.forcePush('4');
            assert(myBuffer.pop() == '3');
            assert(myBuffer.pop() == '4');
            assertThrown(myBuffer.pop(), "Empty buffer should throw exception if popped!");
        }

    }

}
