// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.5.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.5.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";

contract loteria is ERC20, Ownable {
    // gestion tokens

    // direccion del contrato NFT del proyecto
    address public nft;


    // constructor
    constructor() ERC20("Loteria","JA"){
        _mint(address(this), 1000);
        nft = address(new mainERC721());
    }

    // ganador del premio loteria
    address public ganador;

    // registro del usuariio
    mapping(address => address) public  usuario_contract;

    // precio de los tokens
    function precioTokens (uint256 _numTokens) internal pure returns(uint256) {
        return _numTokens * (1 ether);
    }

    // visalizacion del balance de tokens ERC20 de un usuario
    function balanceTokens(address _account) public view returns(uint256) {
        return balanceOf(_account);
    } 

    // visalizacion del balance de tokens ERC20 del smat contrac
    function balanceTokensSC() public view returns(uint256) {
        return balanceOf(address(this));
    } 

    // visualizacion del balance de ethers del smar contract
    function balanceEthersSc() public view returns (uint256){
        return address(this).balance / 10**18;
    } 

    // generacion de nuevos tokens erc20
    function mint(uint256 _cantidad) public onlyOwner {
        _mint(address(this), _cantidad);
    }

    // registro de usuarios
    function registrar() internal {
        address addr_personal_contract = address(new boletosNFTs(msg.sender, address(this), nft));
        usuario_contract[msg.sender] = addr_personal_contract; 
    }

    // informacion de un usuario
    function usersInfo(address _account) public view returns(address){
        return usuario_contract[_account];
    }
}

// smart contract de gestions de nfts
contract mainERC721 is ERC721 {
    address public direccionLoteria;

    constructor() ERC721("Loteria", "STE"){
        direccionLoteria = msg.sender;
    }

    // creacion de nfts
    function safeMint(address _propietario, uint256 _boleto) public {
        require(msg.sender == loteria(direccionLoteria).usersInfo(_propietario), "no tienes permisos para ejecutar esta funcion");
        _safeMint(_propietario, _boleto);
    }

}

contract boletosNFTs {
    // datos relevantes del propietario
    struct Owner {
        address direccionPropietario;
        address contratoPadre;
        address contratoNFT;
        address contratoUsuario;
    }
    // estructura de datos de tipo owner
    Owner public propietario;


    // constructor del smart contrar hijo
    constructor(address _propietario, address _contratoPadre, address _contratoNFT) {
        propietario = Owner(_propietario, _contratoPadre, _contratoNFT, address(this));
    }

    // conversionde los numeros de los boletos de loteria
    function mintBoleto(address _propietario, uint _boleto) public {
        require(msg.sender == propietario.contratoPadre, "No tienes permisos para ejecutar esta funcion");
        mainERC721(propietario.contratoNFT).safeMint(_propietario, _boleto);
    }


}
