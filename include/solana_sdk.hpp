#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <godot_cpp/classes/node.hpp>

namespace godot {

class SolanaSDK : public Node {
    GDCLASS(SolanaSDK, Node)

private:

protected:
    static void _bind_methods();

public:
    SolanaSDK();
    static PackedByteArray bs58_decode(String str);
    static String bs58_encode(PackedByteArray input);
    ~SolanaSDK();
};
}

#endif
