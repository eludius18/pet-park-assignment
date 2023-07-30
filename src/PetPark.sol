// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    // ======= STRUCTS =======

    struct Info {
        uint256 age;
        Gender gender;
    }

    // ======= ENUMS =======

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    // ======= STATE VARIABLES =======

    address owner;
    mapping(AnimalType => uint256) public animalCounts;
    mapping(address => AnimalType) public borrowData;
    mapping(address => Info) public users;

    // ======= EVENTS =======

    event Added(AnimalType animalType, uint256 count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    // ======= MODIFIERS =======

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not owner");
        _;
    }

    // ======= CONSTRUCTOR =======

    constructor() {
        owner = msg.sender;
    }

    // ======= EXTERNAL FUNCTIONS =======

    function add(AnimalType animalType, uint256 count) external onlyOwner {
        require(animalType != AnimalType.None, "Invalid animal");
        animalCounts[animalType] += count;
        emit Added(animalType, count);
    }

    function borrow(uint256 age, Gender gender, AnimalType animalType) public {
        require(age > 0, "Age must be larger than zero");
        require(animalType != AnimalType.None, "Invalid animal type");
        require(animalCounts[animalType] > 0, "Selected animal not available");

        if (users[msg.sender].age == 0) {
            users[msg.sender] = Info(age, gender);
        } else {
            require(users[msg.sender].age == age, "Invalid Age");
            require(users[msg.sender].gender == gender, "Invalid Gender");
            require(borrowData[msg.sender] == AnimalType.None, "Already adopted a pet");
        }

        if (gender == Gender.Male) {
            require(animalType == AnimalType.Fish || animalType == AnimalType.Dog, "Invalid animal for men");
        } else {
            if (age < 40) {
                require(animalType != AnimalType.Cat, "Invalid animal for women under 40");
            }
        }

        animalCounts[animalType]--;
        borrowData[msg.sender] = animalType;
        emit Borrowed(animalType);
    }

    function giveBackAnimal() public {
        AnimalType borrowed = borrowData[msg.sender];
        require(borrowed != AnimalType.None, "No borrowed pets");

        animalCounts[borrowed]++;
        borrowData[msg.sender] = AnimalType.None; // Fixed the assignment here
        emit Returned(borrowed);
    }
}