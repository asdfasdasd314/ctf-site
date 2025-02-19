#include <iostream>
#include <string>
#include <cstring>

using namespace std;

struct ProgramState {
    char* buffer1_ptr;
    char* buffer2_ptr;
    string buffer1_content;
    string buffer2_content;
};

extern "C" {
    ProgramState newProgramState(const char* buffer1_content, string buffer2_content) {
        char* buffer1_ptr = (char*)malloc(8 * sizeof(char));
        strncpy(buffer1_ptr, buffer1_content, 8);
        return {

        };
    }
}

void printBuffers() {
    cout << "Heap State:\n";
    cout << "+-------------+----------------+\n";
    cout << "[*] Address   ->   Heap Data   \n";
    cout << "+-------------+----------------+\n";
    cout << "[*]   " << &buffer1 << "  ->   " << buffer1 << "\n";
    cout << "+-------------+----------------+\n";
    cout << "[*]   " << &buffer2 << "  ->   " << buffer2 << "\n";
    cout << "+-------------+----------------+" << endl;
}

void setup() {
    buffer1 = (char*)malloc(8 * sizeof(char));
    strncpy(buffer1, "Buffer1", 8);
    buffer2 = (char*)malloc(13 * sizeof(char));
    strncpy(buffer2, "Unbreakable!", 13);
}

void updateBuffer1() {
    cout << "Enter the new value for Buffer1: " << endl;
    scanf("%s", buffer1);
}

bool checkOkay() {
    if (strcmp(buffer2, "Unbreakable!") != 0) {
        cout << "Buffer2 has been tampered with!" << endl;
        return false;
    }

    cout << "Buffer 2 Cannot be Broken!" << endl;
    return true;
}

int main() {
    setup();
    printBuffers();
    while (true) {
        cout << "What do you want to do?\n1. Update Buffer1\n2. Print Buffers\n3. Check everything is okay\n4. Exit" << endl;
        string input; // While it would be more efficient to use an int, the memory usage is neglible
        cin >> input;
        cout << endl;
        if (input == "1") {
            updateBuffer1();
        } else if (input == "2") {
            printBuffers();
            
        } else if (input == "3") {
            if (checkOkay()) {
                cout << "Everything is okay!" << endl;
            }
            else {
                cout << "You Win!" << endl;
                break;
            }
        } else if (input == "4") {
            break;
        } else {
            cout << "Invalid input" << endl;
        }
        cout << endl;
    }

    return 0;
}