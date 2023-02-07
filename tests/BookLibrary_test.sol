// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.17;

import "remix_tests.sol"; 
import "remix_accounts.sol";
import "../contracts/BookLibrary.sol";

/// @dev Tests for the BookLibrary contract
contract BookLibraryTests is BookLibrary {
    /// Define variables referring to different accounts
    address public acc0;
    address public acc1;
    address public acc2;
    
    /// Initiate accounts variable
    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0); 
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
    }


    // @dev Test to add a book to the library. Check if the book is added successfully.
    function testAddBook() public {
        addBook("One Hundred Years of Solitude");
        addBook("One Hundred Years of Solitude");
        addBook("One Hundred Years of Solitude");
        addBook("One Hundred Years of Solitude");
        addBook("One Hundred Years of Solitude");
        
        Book memory book = this.getBookByTitle("One Hundred Years of Solitude");
        Assert.equal(book.title, "One Hundred Years of Solitude", "The title of the book is not correct");
        Assert.equal(book.copies, 5, "The number of copies is not correct");
    }

    /// #sender: account-1
    function testOnlyOnwerCanAddBooks() public {
        string memory title = "Rayuela";
        addBook(title);

        // The transaction will be reverted but we can't test this as in order to call try/catch we need to call the function
        // externally which will lose the contex   
    }

    /// @dev Test to view the books in the library. Check if the book list is correct.
    function testGetAllBooks() public {
        // Add 3 copies of a new book
        addBook("1984");
        addBook("1984");
        addBook("1984");

        // Add 1 copy of a new book
        addBook("Pride and Prejudice");

        uint numberOfBooks = this.getNumberOfBooks();
        Book[] memory bookList = new Book[](numberOfBooks);

        for (uint i=0; i < numberOfBooks; i++) {
            bytes32 bookKey = this.bookKeys(i);
            Book memory book = this.getBookByKey(bookKey);
            bookList[i] = book;
        }
        
        Assert.equal(bookList[0].title, "One Hundred Years of Solitude", "The first book title is not correct");
        Assert.equal(bookList[1].title, "1984", "The second book title is not correct");
        Assert.equal(bookList[2].title, "Pride and Prejudice", "The third book title is not correct");
        Assert.equal(bookList[0].copies, 5, "The number of copies of the first book is not correct");
        Assert.equal(bookList[1].copies, 3, "The number of copies of the second book is not correct");
        Assert.equal(bookList[2].copies, 1, "The number of copies of the third book is not correct");
    }
    

    /// #sender: account-1
    /// @dev Test to borrow a book from the library. Check if the book is borrowed successfully.
    function testBorrowBook() public {
        string memory title = "One Hundred Years of Solitude";
        // get key
        bytes32 bookKey = keccak256(abi.encodePacked(title));

        borrowBook(title);   

        bool isBorrowedAcc1 = this.borrowedBook(acc1, bookKey);
        Assert.equal(isBorrowedAcc1, true, "The book is not borrowed by account1");
    }

    // @dev Test to borrow a book from the library. Check if the book is borrowed successfully.
    function testDoubleBorrowingShouldFail() public {
        string memory title = "1984";
        // calling externally to be able to use try. Using the contract address as caller
        this.borrowBook(title);   
        
        // calling externally to be able to use try
        try this.borrowBook(title) {
            Assert.ok(false, "method execution should fail");
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, "You have already borrowed this book.", "failed with unexpected reason");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "Failed unexpectedly");
        }
    }
    
    ///  #sender: account-3
    function testNoMoreCopiesAvailable() public {
        string memory title = "Pride and Prejudice";
        borrowBook(title);
     
        // Now all copies should be borrowed and the function should revert

        // calling externally to be able to use try and to use a different address
        // this is gas inneficient but is acceptable for testing purposes
        try this.borrowBook(title) {
            Assert.ok(false, "method execution should fail");
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, "There are no more available copies of this book.", "failed with unexpected reason");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "Failed unexpectedly");
        }
    }
}
    