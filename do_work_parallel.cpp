// Do work parallel.
// read command(every line) from stdin.
#include <cstdlib>

#include <iostream>
#include <memory>
#include <string>
#include <thread>
#include <vector>

#include <boost/lockfree/queue.hpp>

// clang++ -g -O0 -std=c++11 -stdlib=libc++ -I ~/3/code_third/boost/ do_work_parallel.cpp

struct ThreadWrapper
{
    template <class Function, class... Args>
    explicit ThreadWrapper(Function&& f, Args&&... args):
        thread(std::forward<Function>(f), args...)
    {}

    ~ThreadWrapper()
    {
        thread.join();
    }

    std::thread thread;
};

void do_work(boost::lockfree::queue<std::string>& command_queue)
{
    std::string command;
    while (command_queue.pop(command)) {
        std::cout << "command: " << command << std::endl;
        int return_code = system(command.c_str());
        std::cout << "command: " << command << " return: " << return_code << std::endl;
    }
}

int main()
{
    boost::lockfree::queue<std::string> command_queue(0);
    {
        std::string command;
        while (std::getline(std::cin, command)) {
            std::cout << "command: " << command
                << " add result: " << command_queue.push(command) << std::endl;
        }
    }
    const size_t thread_num = 8;
    std::vector<std::shared_ptr<ThreadWrapper> > thread_group;
    for (size_t i = 0; i < thread_num; ++i) {
        thread_group.push_back(std::make_shared<ThreadWrapper>(do_work, std::ref(command_queue)));
    }
    return 0;
}

