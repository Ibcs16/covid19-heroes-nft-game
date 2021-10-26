// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

import "./libraries/Base64.sol";

contract MyEpicGame is ERC721 {
    struct HeroVaccineLab {
        uint characterIndex;
        string lab_name;
        string imageURI;
        uint available_vaccines;
        uint used_vaccines;
        string first_appearance_date;
        uint attack_demage;
        // string[] taken_countries;
    }

    struct EvilPresident {
        string name;
        string imageURI;
        string country;
        uint n_saying_no;
        uint vaccines_taken;
        uint population;
        uint attack_demage;
    }

    HeroVaccineLab[] defaultHeroVaccineLabs;
    EvilPresident public evilPresident;

    // The tokenId is the NFTs unique identifier, it's just a number that goes
    // 0, 1, 2, 3, etc.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // We create a mapping from the nft's tokenId => that NFTs attributes.
    mapping(uint256 => HeroVaccineLab) public nftHolderAttributes;

    // A mapping from an address => the NFTs tokenId. Gives me an ez way
    // to store the owner of the NFT and reference it later.
    mapping(address => uint256) public nftHolders;

    event HeroVaccineLabNFTMinted(address sender, uint256 tokenId, uint256 vaccineLabIndex);
    event AttackComplete(uint bossVaccinesTaken, uint vaccinesUsedByLab, uint newAvailableVaccines);

    constructor(
        string[] memory vaccineNames,
        string[] memory vaccineImages,
        uint[] memory vaccineAvailableVaccines,
        string[] memory vaccineFirstAppearanceDate,
        uint[] memory vaccineAttackDamage,
        string memory bossName,
        string memory bossImageURI,
        string memory bossCountry,
        uint   bossAttackDemage
        // ERC721 identifier, like Ethereum and ETH
    ) ERC721("Covid19Vaccines", "CV19Vaccine") {
        for(uint i = 0; i < vaccineNames.length; i++) {
            defaultHeroVaccineLabs.push(HeroVaccineLab({
                characterIndex: i,
                lab_name: vaccineNames[i],
                imageURI: vaccineImages[i],
                available_vaccines: vaccineAvailableVaccines[i],
                used_vaccines: 0,
                first_appearance_date: vaccineFirstAppearanceDate[i],
                attack_demage: vaccineAttackDamage[i]
                // taken_countries: []
            }));

            HeroVaccineLab memory vaccineLab = defaultHeroVaccineLabs[i];
            console.log('Done initializing %s w/ %s, img %s', vaccineLab.lab_name, vaccineLab.available_vaccines, vaccineLab.imageURI);
        }
        _tokenIds.increment();

        evilPresident = EvilPresident({
            name: bossName,
            imageURI: bossImageURI,
            country:bossCountry,
            n_saying_no: 0,
            vaccines_taken: 0,
            population: 100000000,
            attack_demage: bossAttackDemage
        }
        );

        console.log("Done initializing boss %s w/ HP %s, img %s", evilPresident.name, evilPresident.country, evilPresident.imageURI);
    }

    function mintVaccineLab(uint  _vaccineLabIndex,  string memory _appearance_date) external {
        // get current tokenId
        uint256 newItemId = _tokenIds.current();

        // assign token to sender wallet address
        _safeMint(msg.sender, newItemId);

        HeroVaccineLab memory baseVaccineLab = defaultHeroVaccineLabs[_vaccineLabIndex];
        baseVaccineLab.first_appearance_date = _appearance_date;
        baseVaccineLab.available_vaccines = baseVaccineLab.available_vaccines + (defaultHeroVaccineLabs.length * 10);

        // set vaccineLab copy's data for new item
        nftHolderAttributes[newItemId] = baseVaccineLab;

        console.log("Minted NFT w/ tokenId %s and vaccineLabIndex %s", newItemId, _vaccineLabIndex);

        // Keep an easy way to see who owns what NFT.
        nftHolders[msg.sender] = newItemId;

        // Increment the tokenId for the next person that uses it.
        _tokenIds.increment();
        emit HeroVaccineLabNFTMinted(msg.sender, newItemId, _vaccineLabIndex);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        HeroVaccineLab memory holderVaccineLab = nftHolderAttributes[_tokenId];

        string memory strAvailableVaccines = Strings.toString(holderVaccineLab.available_vaccines);
        uint max_available_vaccines = holderVaccineLab.available_vaccines + holderVaccineLab.used_vaccines;
        string memory strMaxAvailable = Strings.toString(max_available_vaccines);
        string memory strUsedVaccines = Strings.toString(holderVaccineLab.used_vaccines);

         string memory json = Base64.encode(
            bytes(
            string(
                abi.encodePacked(
                '{"name": "',
                holderVaccineLab.lab_name,
                ' -- NFT #: ',
                Strings.toString(_tokenId),
                '", "description": "This is an NFT that lets people play in the game Vaccinate the President of Brazil!", "image": "',
                holderVaccineLab.imageURI,
                '", "attributes": [ { "trait_type": "Available Vaccines", "value": ',strAvailableVaccines,', "max_value":',strMaxAvailable,'}, { "trait_type": "Used Vaccines", "value": ',
                strUsedVaccines,'} ]}'
                )
            )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        
        return output;
    }

    function attackBoss() public {
        uint256 tokenId = nftHolders[msg.sender];
        HeroVaccineLab storage vaccineLab = nftHolderAttributes[tokenId];
        console.log("\nvaccineLab w/ character %s about to throw vaccines. Has %s vaccines and %s used", vaccineLab.lab_name, vaccineLab.available_vaccines, vaccineLab.used_vaccines);
        console.log("Boss %s has taken %s vaccines and has said %s no's", evilPresident.name, evilPresident.vaccines_taken, evilPresident.n_saying_no);

        require(vaccineLab.available_vaccines > 0, "Lab has ran out of vaccines");
        require(evilPresident.vaccines_taken < (evilPresident.population * 2), "Population fully vaccinated");

        if(evilPresident.vaccines_taken + vaccineLab.attack_demage > evilPresident.population * 2 ) {
            evilPresident.vaccines_taken = 0;
        } else {
            evilPresident.vaccines_taken += vaccineLab.attack_demage;
            vaccineLab.available_vaccines -= vaccineLab.attack_demage;
            vaccineLab.used_vaccines += vaccineLab.attack_demage;
        }

        if(vaccineLab.available_vaccines < evilPresident.attack_demage) {
            vaccineLab.available_vaccines = 0;
        } else {
            vaccineLab.available_vaccines -= evilPresident.attack_demage;
            evilPresident.n_saying_no++;
        }

        emit AttackComplete(evilPresident.vaccines_taken, vaccineLab.used_vaccines, vaccineLab.available_vaccines);
    } 

    function checkIfUserHasNFT() public view returns (HeroVaccineLab memory) {
        uint256 userNFTTokenID = nftHolders[msg.sender];

        if(userNFTTokenID > 0) {
            return nftHolderAttributes[userNFTTokenID];
        } else {
            HeroVaccineLab memory emptyStruct;
            return emptyStruct;
        }
    }

    function getAllDefaultVaccineLabs() public view returns (HeroVaccineLab[] memory) {
        return defaultHeroVaccineLabs;
    }

    function getEvilPresident() public view returns (EvilPresident memory) {
        return evilPresident;
    }


}