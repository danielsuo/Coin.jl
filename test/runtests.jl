using Coin
using Base.Test

##############################################################################
##
## Crypto tests
##
##############################################################################

# SHA2 tests
@test Coin.Crypto.SHA2.sha256("a", is_hex=false) == "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"
@test Coin.Crypto.SHA2.sha256("Scientific progress goes 'boink'", is_hex=false) == "2f2ba2a09a66771bf1fdf541af6e9db4b443145f9935ddd5d4c323c21a8bdcee"
@test Coin.Crypto.SHA2.sha256("I'd hold you up to say to your mother, 'this kid's gonna be the best kid in the world. This kid's gonna be somebody better than anybody I ever knew.' And you grew up good and wonderful. It was great just watching you, every day was like a privilege. Then the time come for you to be your own man and take on the world, and you did. But somewhere along the line, you changed. You stopped being you. You let people stick a finger in your face and tell you you're no good. And when things got hard, you started looking for something to blame, like a big shadow. Let me tell you something you already know. The world ain't all sunshine and rainbows. It's a very mean and nasty place and I don't care how tough you are it will beat you to your knees and keep you there permanently if you let it. You, me, or nobody is gonna hit as hard as life. But it ain't about how hard ya hit. It's about how hard you can get hit and keep moving forward. How much you can take and keep moving forward. That's how winning is done! Now if you know what you're worth then go out and get what you're worth. But ya gotta be willing to take the hits, and not pointing fingers saying you ain't where you wanna be because of him, or her, or anybody! Cowards do that and that ain't you! You're better than that! I'm always gonna love you no matter what. No matter what happens. You're my son and you're my blood. You're the best thing in my life. But until you start believing in yourself, ya ain't gonna have a life. Don't forget to visit your mother.", is_hex=false) == "a5d8cfb99203ae8cd0c222e8aaef815a7a53493f650c5dec0d73de7f912e91f2"

# Test > 448 bits (> 56 characters)
@test Coin.Crypto.SHA2.sha256("asdfghjkqwasdfghjkqwasdfghjkqwasdfghjkqwasdfghjkqwasdfghjkqw", is_hex=false) == "07a95e647687cf0e8cd3d0ca78c9cc9b120ab41497f5f3be912c6c3f1ecd3a31"

# Testing hex strings
@test Coin.Crypto.SHA2.sha256("800c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d") == "8147786c4d15106333bf278d71dadaf1079ef2d2440a4dde37d747ded5403592"
@test Coin.Crypto.SHA2.sha256("8147786c4d15106333bf278d71dadaf1079ef2d2440a4dde37d747ded5403592") == "507a5b8dfed0fc6fe8801743720cedec06aa5c6fca72b07c49964492fb98a714"

##############################################################################
##
## Util tests
##
##############################################################################

base58data = parseint(BigInt, "800c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d507a5b8d", 16)

# Base 58 encoding
@test Coin.Util.Base.encode(base58data, 58) == "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"

# Base 58 decoding
@test Coin.Util.Base.decode("5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ", 58) == base58data

##############################################################################
##
## Wallet Interchange Format tests
##
##############################################################################

# Private key to WIF
@test Coin.Wallet.WIF.private2wif("0c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d") == "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"

# WIF to private key
@test Coin.Wallet.WIF.wif2private("5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ") == "0c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d"

# WIF checksum
@test Coin.Wallet.WIF.wif_checksum("5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ")

