
bomb:     file format elf32-i386


Disassembly of section .init:

08048768 <_init>:
 8048768:	55                   	push   %ebp
 8048769:	89 e5                	mov    %esp,%ebp
 804876b:	53                   	push   %ebx
 804876c:	83 ec 04             	sub    $0x4,%esp
 804876f:	e8 00 00 00 00       	call   8048774 <_init+0xc>
 8048774:	5b                   	pop    %ebx
 8048775:	81 c3 80 38 00 00    	add    $0x3880,%ebx
 804877b:	8b 93 fc ff ff ff    	mov    -0x4(%ebx),%edx
 8048781:	85 d2                	test   %edx,%edx
 8048783:	74 05                	je     804878a <_init+0x22>
 8048785:	e8 5e 00 00 00       	call   80487e8 <__gmon_start__@plt>
 804878a:	e8 b1 02 00 00       	call   8048a40 <frame_dummy>
 804878f:	e8 ec 15 00 00       	call   8049d80 <__do_global_ctors_aux>
 8048794:	58                   	pop    %eax
 8048795:	5b                   	pop    %ebx
 8048796:	c9                   	leave  
 8048797:	c3                   	ret    

Disassembly of section .plt:

08048798 <__errno_location@plt-0x10>:
 8048798:	ff 35 f8 bf 04 08    	pushl  0x804bff8
 804879e:	ff 25 fc bf 04 08    	jmp    *0x804bffc
 80487a4:	00 00                	add    %al,(%eax)
	...

080487a8 <__errno_location@plt>:
 80487a8:	ff 25 00 c0 04 08    	jmp    *0x804c000
 80487ae:	68 00 00 00 00       	push   $0x0
 80487b3:	e9 e0 ff ff ff       	jmp    8048798 <_init+0x30>

080487b8 <connect@plt>:
 80487b8:	ff 25 04 c0 04 08    	jmp    *0x804c004
 80487be:	68 08 00 00 00       	push   $0x8
 80487c3:	e9 d0 ff ff ff       	jmp    8048798 <_init+0x30>

080487c8 <__fprintf_chk@plt>:
 80487c8:	ff 25 08 c0 04 08    	jmp    *0x804c008
 80487ce:	68 10 00 00 00       	push   $0x10
 80487d3:	e9 c0 ff ff ff       	jmp    8048798 <_init+0x30>

080487d8 <signal@plt>:
 80487d8:	ff 25 0c c0 04 08    	jmp    *0x804c00c
 80487de:	68 18 00 00 00       	push   $0x18
 80487e3:	e9 b0 ff ff ff       	jmp    8048798 <_init+0x30>

080487e8 <__gmon_start__@plt>:
 80487e8:	ff 25 10 c0 04 08    	jmp    *0x804c010
 80487ee:	68 20 00 00 00       	push   $0x20
 80487f3:	e9 a0 ff ff ff       	jmp    8048798 <_init+0x30>

080487f8 <rewind@plt>:
 80487f8:	ff 25 14 c0 04 08    	jmp    *0x804c014
 80487fe:	68 28 00 00 00       	push   $0x28
 8048803:	e9 90 ff ff ff       	jmp    8048798 <_init+0x30>

08048808 <__isoc99_sscanf@plt>:
 8048808:	ff 25 18 c0 04 08    	jmp    *0x804c018
 804880e:	68 30 00 00 00       	push   $0x30
 8048813:	e9 80 ff ff ff       	jmp    8048798 <_init+0x30>

08048818 <__printf_chk@plt>:
 8048818:	ff 25 1c c0 04 08    	jmp    *0x804c01c
 804881e:	68 38 00 00 00       	push   $0x38
 8048823:	e9 70 ff ff ff       	jmp    8048798 <_init+0x30>

08048828 <getenv@plt>:
 8048828:	ff 25 20 c0 04 08    	jmp    *0x804c020
 804882e:	68 40 00 00 00       	push   $0x40
 8048833:	e9 60 ff ff ff       	jmp    8048798 <_init+0x30>

08048838 <system@plt>:
 8048838:	ff 25 24 c0 04 08    	jmp    *0x804c024
 804883e:	68 48 00 00 00       	push   $0x48
 8048843:	e9 50 ff ff ff       	jmp    8048798 <_init+0x30>

08048848 <write@plt>:
 8048848:	ff 25 28 c0 04 08    	jmp    *0x804c028
 804884e:	68 50 00 00 00       	push   $0x50
 8048853:	e9 40 ff ff ff       	jmp    8048798 <_init+0x30>

08048858 <fgets@plt>:
 8048858:	ff 25 2c c0 04 08    	jmp    *0x804c02c
 804885e:	68 58 00 00 00       	push   $0x58
 8048863:	e9 30 ff ff ff       	jmp    8048798 <_init+0x30>

08048868 <__libc_start_main@plt>:
 8048868:	ff 25 30 c0 04 08    	jmp    *0x804c030
 804886e:	68 60 00 00 00       	push   $0x60
 8048873:	e9 20 ff ff ff       	jmp    8048798 <_init+0x30>

08048878 <__strcat_chk@plt>:
 8048878:	ff 25 34 c0 04 08    	jmp    *0x804c034
 804887e:	68 68 00 00 00       	push   $0x68
 8048883:	e9 10 ff ff ff       	jmp    8048798 <_init+0x30>

08048888 <tmpfile@plt>:
 8048888:	ff 25 38 c0 04 08    	jmp    *0x804c038
 804888e:	68 70 00 00 00       	push   $0x70
 8048893:	e9 00 ff ff ff       	jmp    8048798 <_init+0x30>

08048898 <strtol@plt>:
 8048898:	ff 25 3c c0 04 08    	jmp    *0x804c03c
 804889e:	68 78 00 00 00       	push   $0x78
 80488a3:	e9 f0 fe ff ff       	jmp    8048798 <_init+0x30>

080488a8 <inet_pton@plt>:
 80488a8:	ff 25 40 c0 04 08    	jmp    *0x804c040
 80488ae:	68 80 00 00 00       	push   $0x80
 80488b3:	e9 e0 fe ff ff       	jmp    8048798 <_init+0x30>

080488b8 <fflush@plt>:
 80488b8:	ff 25 44 c0 04 08    	jmp    *0x804c044
 80488be:	68 88 00 00 00       	push   $0x88
 80488c3:	e9 d0 fe ff ff       	jmp    8048798 <_init+0x30>

080488c8 <socket@plt>:
 80488c8:	ff 25 48 c0 04 08    	jmp    *0x804c048
 80488ce:	68 90 00 00 00       	push   $0x90
 80488d3:	e9 c0 fe ff ff       	jmp    8048798 <_init+0x30>

080488d8 <__ctype_b_loc@plt>:
 80488d8:	ff 25 4c c0 04 08    	jmp    *0x804c04c
 80488de:	68 98 00 00 00       	push   $0x98
 80488e3:	e9 b0 fe ff ff       	jmp    8048798 <_init+0x30>

080488e8 <fclose@plt>:
 80488e8:	ff 25 50 c0 04 08    	jmp    *0x804c050
 80488ee:	68 a0 00 00 00       	push   $0xa0
 80488f3:	e9 a0 fe ff ff       	jmp    8048798 <_init+0x30>

080488f8 <dup@plt>:
 80488f8:	ff 25 54 c0 04 08    	jmp    *0x804c054
 80488fe:	68 a8 00 00 00       	push   $0xa8
 8048903:	e9 90 fe ff ff       	jmp    8048798 <_init+0x30>

08048908 <fopen@plt>:
 8048908:	ff 25 58 c0 04 08    	jmp    *0x804c058
 804890e:	68 b0 00 00 00       	push   $0xb0
 8048913:	e9 80 fe ff ff       	jmp    8048798 <_init+0x30>

08048918 <__strcpy_chk@plt>:
 8048918:	ff 25 5c c0 04 08    	jmp    *0x804c05c
 804891e:	68 b8 00 00 00       	push   $0xb8
 8048923:	e9 70 fe ff ff       	jmp    8048798 <_init+0x30>

08048928 <close@plt>:
 8048928:	ff 25 60 c0 04 08    	jmp    *0x804c060
 804892e:	68 c0 00 00 00       	push   $0xc0
 8048933:	e9 60 fe ff ff       	jmp    8048798 <_init+0x30>

08048938 <cuserid@plt>:
 8048938:	ff 25 64 c0 04 08    	jmp    *0x804c064
 804893e:	68 c8 00 00 00       	push   $0xc8
 8048943:	e9 50 fe ff ff       	jmp    8048798 <_init+0x30>

08048948 <__stack_chk_fail@plt>:
 8048948:	ff 25 68 c0 04 08    	jmp    *0x804c068
 804894e:	68 d0 00 00 00       	push   $0xd0
 8048953:	e9 40 fe ff ff       	jmp    8048798 <_init+0x30>

08048958 <sleep@plt>:
 8048958:	ff 25 6c c0 04 08    	jmp    *0x804c06c
 804895e:	68 d8 00 00 00       	push   $0xd8
 8048963:	e9 30 fe ff ff       	jmp    8048798 <_init+0x30>

08048968 <__sprintf_chk@plt>:
 8048968:	ff 25 70 c0 04 08    	jmp    *0x804c070
 804896e:	68 e0 00 00 00       	push   $0xe0
 8048973:	e9 20 fe ff ff       	jmp    8048798 <_init+0x30>

08048978 <__memmove_chk@plt>:
 8048978:	ff 25 74 c0 04 08    	jmp    *0x804c074
 804897e:	68 e8 00 00 00       	push   $0xe8
 8048983:	e9 10 fe ff ff       	jmp    8048798 <_init+0x30>

08048988 <gethostbyname@plt>:
 8048988:	ff 25 78 c0 04 08    	jmp    *0x804c078
 804898e:	68 f0 00 00 00       	push   $0xf0
 8048993:	e9 00 fe ff ff       	jmp    8048798 <_init+0x30>

08048998 <exit@plt>:
 8048998:	ff 25 7c c0 04 08    	jmp    *0x804c07c
 804899e:	68 f8 00 00 00       	push   $0xf8
 80489a3:	e9 f0 fd ff ff       	jmp    8048798 <_init+0x30>

Disassembly of section .text:

080489b0 <_start>:
 80489b0:	31 ed                	xor    %ebp,%ebp
 80489b2:	5e                   	pop    %esi
 80489b3:	89 e1                	mov    %esp,%ecx
 80489b5:	83 e4 f0             	and    $0xfffffff0,%esp
 80489b8:	50                   	push   %eax
 80489b9:	54                   	push   %esp
 80489ba:	52                   	push   %edx
 80489bb:	68 10 9d 04 08       	push   $0x8049d10
 80489c0:	68 20 9d 04 08       	push   $0x8049d20
 80489c5:	51                   	push   %ecx
 80489c6:	56                   	push   %esi
 80489c7:	68 64 8a 04 08       	push   $0x8048a64
 80489cc:	e8 97 fe ff ff       	call   8048868 <__libc_start_main@plt>
 80489d1:	f4                   	hlt    
 80489d2:	90                   	nop
 80489d3:	90                   	nop
 80489d4:	90                   	nop
 80489d5:	90                   	nop
 80489d6:	90                   	nop
 80489d7:	90                   	nop
 80489d8:	90                   	nop
 80489d9:	90                   	nop
 80489da:	90                   	nop
 80489db:	90                   	nop
 80489dc:	90                   	nop
 80489dd:	90                   	nop
 80489de:	90                   	nop
 80489df:	90                   	nop

080489e0 <__do_global_dtors_aux>:
 80489e0:	55                   	push   %ebp
 80489e1:	89 e5                	mov    %esp,%ebp
 80489e3:	53                   	push   %ebx
 80489e4:	83 ec 04             	sub    $0x4,%esp
 80489e7:	80 3d e4 c5 04 08 00 	cmpb   $0x0,0x804c5e4
 80489ee:	75 3f                	jne    8048a2f <__do_global_dtors_aux+0x4f>
 80489f0:	a1 e8 c5 04 08       	mov    0x804c5e8,%eax
 80489f5:	bb 20 bf 04 08       	mov    $0x804bf20,%ebx
 80489fa:	81 eb 1c bf 04 08    	sub    $0x804bf1c,%ebx
 8048a00:	c1 fb 02             	sar    $0x2,%ebx
 8048a03:	83 eb 01             	sub    $0x1,%ebx
 8048a06:	39 d8                	cmp    %ebx,%eax
 8048a08:	73 1e                	jae    8048a28 <__do_global_dtors_aux+0x48>
 8048a0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 8048a10:	83 c0 01             	add    $0x1,%eax
 8048a13:	a3 e8 c5 04 08       	mov    %eax,0x804c5e8
 8048a18:	ff 14 85 1c bf 04 08 	call   *0x804bf1c(,%eax,4)
 8048a1f:	a1 e8 c5 04 08       	mov    0x804c5e8,%eax
 8048a24:	39 d8                	cmp    %ebx,%eax
 8048a26:	72 e8                	jb     8048a10 <__do_global_dtors_aux+0x30>
 8048a28:	c6 05 e4 c5 04 08 01 	movb   $0x1,0x804c5e4
 8048a2f:	83 c4 04             	add    $0x4,%esp
 8048a32:	5b                   	pop    %ebx
 8048a33:	5d                   	pop    %ebp
 8048a34:	c3                   	ret    
 8048a35:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 8048a39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

08048a40 <frame_dummy>:
 8048a40:	55                   	push   %ebp
 8048a41:	89 e5                	mov    %esp,%ebp
 8048a43:	83 ec 18             	sub    $0x18,%esp
 8048a46:	a1 24 bf 04 08       	mov    0x804bf24,%eax
 8048a4b:	85 c0                	test   %eax,%eax
 8048a4d:	74 12                	je     8048a61 <frame_dummy+0x21>
 8048a4f:	b8 00 00 00 00       	mov    $0x0,%eax
 8048a54:	85 c0                	test   %eax,%eax
 8048a56:	74 09                	je     8048a61 <frame_dummy+0x21>
 8048a58:	c7 04 24 24 bf 04 08 	movl   $0x804bf24,(%esp)
 8048a5f:	ff d0                	call   *%eax
 8048a61:	c9                   	leave  
 8048a62:	c3                   	ret    
 8048a63:	90                   	nop

08048a64 <main>:
 8048a64:	55                   	push   %ebp
 8048a65:	89 e5                	mov    %esp,%ebp
 8048a67:	83 e4 f0             	and    $0xfffffff0,%esp
 8048a6a:	56                   	push   %esi
 8048a6b:	53                   	push   %ebx
 8048a6c:	83 ec 18             	sub    $0x18,%esp
 8048a6f:	8b 45 08             	mov    0x8(%ebp),%eax
 8048a72:	8b 75 0c             	mov    0xc(%ebp),%esi
 8048a75:	83 f8 01             	cmp    $0x1,%eax
 8048a78:	75 0c                	jne    8048a86 <main+0x22>
 8048a7a:	a1 c0 c5 04 08       	mov    0x804c5c0,%eax
 8048a7f:	a3 f0 c5 04 08       	mov    %eax,0x804c5f0
 8048a84:	eb 75                	jmp    8048afb <main+0x97>
 8048a86:	83 f8 02             	cmp    $0x2,%eax
 8048a89:	75 4a                	jne    8048ad5 <main+0x71>
 8048a8b:	8d 5e 04             	lea    0x4(%esi),%ebx
 8048a8e:	c7 44 24 04 99 a1 04 	movl   $0x804a199,0x4(%esp)
 8048a95:	08 
 8048a96:	8b 03                	mov    (%ebx),%eax
 8048a98:	89 04 24             	mov    %eax,(%esp)
 8048a9b:	e8 68 fe ff ff       	call   8048908 <fopen@plt>
 8048aa0:	a3 f0 c5 04 08       	mov    %eax,0x804c5f0
 8048aa5:	85 c0                	test   %eax,%eax
 8048aa7:	75 52                	jne    8048afb <main+0x97>
 8048aa9:	8b 03                	mov    (%ebx),%eax
 8048aab:	89 44 24 0c          	mov    %eax,0xc(%esp)
 8048aaf:	8b 06                	mov    (%esi),%eax
 8048ab1:	89 44 24 08          	mov    %eax,0x8(%esp)
 8048ab5:	c7 44 24 04 e8 9d 04 	movl   $0x8049de8,0x4(%esp)
 8048abc:	08 
 8048abd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8048ac4:	e8 4f fd ff ff       	call   8048818 <__printf_chk@plt>
 8048ac9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 8048ad0:	e8 c3 fe ff ff       	call   8048998 <exit@plt>
 8048ad5:	8b 06                	mov    (%esi),%eax
 8048ad7:	89 44 24 08          	mov    %eax,0x8(%esp)
 8048adb:	c7 44 24 04 05 9e 04 	movl   $0x8049e05,0x4(%esp)
 8048ae2:	08 
 8048ae3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8048aea:	e8 29 fd ff ff       	call   8048818 <__printf_chk@plt>
 8048aef:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 8048af6:	e8 9d fe ff ff       	call   8048998 <exit@plt>
 8048afb:	e8 d0 11 00 00       	call   8049cd0 <initialize_bomb>
 8048b00:	c7 44 24 04 30 9e 04 	movl   $0x8049e30,0x4(%esp)
 8048b07:	08 
 8048b08:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8048b0f:	e8 04 fd ff ff       	call   8048818 <__printf_chk@plt>
 8048b14:	c7 44 24 04 6c 9e 04 	movl   $0x8049e6c,0x4(%esp)
 8048b1b:	08 
 8048b1c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8048b23:	e8 f0 fc ff ff       	call   8048818 <__printf_chk@plt>
 8048b28:	e8 7e 0f 00 00       	call   8049aab <read_line>
 8048b2d:	89 04 24             	mov    %eax,(%esp)
 8048b30:	e8 32 05 00 00       	call   8049067 <phase_1>
 8048b35:	e8 f8 0d 00 00       	call   8049932 <phase_defused>
 8048b3a:	c7 44 24 04 9c 9e 04 	movl   $0x8049e9c,0x4(%esp)
 8048b41:	08 
 8048b42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8048b49:	e8 ca fc ff ff       	call   8048818 <__printf_chk@plt>
 8048b4e:	e8 58 0f 00 00       	call   8049aab <read_line>
 8048b53:	89 04 24             	mov    %eax,(%esp)
 8048b56:	e8 92 02 00 00       	call   8048ded <phase_2>
 8048b5b:	e8 d2 0d 00 00       	call   8049932 <phase_defused>
 8048b60:	c7 44 24 04 c8 9e 04 	movl   $0x8049ec8,0x4(%esp)
 8048b67:	08 
 8048b68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8048b6f:	e8 a4 fc ff ff       	call   8048818 <__printf_chk@plt>
 8048b74:	e8 32 0f 00 00       	call   8049aab <read_line>
 8048b79:	89 04 24             	mov    %eax,(%esp)
 8048b7c:	e8 80 03 00 00       	call   8048f01 <phase_3>
 8048b81:	e8 ac 0d 00 00       	call   8049932 <phase_defused>
 8048b86:	c7 44 24 04 1f 9e 04 	movl   $0x8049e1f,0x4(%esp)
 8048b8d:	08 
 8048b8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8048b95:	e8 7e fc ff ff       	call   8048818 <__printf_chk@plt>
 8048b9a:	e8 0c 0f 00 00       	call   8049aab <read_line>
 8048b9f:	89 04 24             	mov    %eax,(%esp)
 8048ba2:	e8 0b 03 00 00       	call   8048eb2 <phase_4>
 8048ba7:	e8 86 0d 00 00       	call   8049932 <phase_defused>
 8048bac:	c7 44 24 04 e8 9e 04 	movl   $0x8049ee8,0x4(%esp)
 8048bb3:	08 
 8048bb4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8048bbb:	e8 58 fc ff ff       	call   8048818 <__printf_chk@plt>
 8048bc0:	e8 e6 0e 00 00       	call   8049aab <read_line>
 8048bc5:	89 04 24             	mov    %eax,(%esp)
 8048bc8:	e8 6f 02 00 00       	call   8048e3c <phase_5>
 8048bcd:	e8 60 0d 00 00       	call   8049932 <phase_defused>
 8048bd2:	c7 44 24 04 10 9f 04 	movl   $0x8049f10,0x4(%esp)
 8048bd9:	08 
 8048bda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8048be1:	e8 32 fc ff ff       	call   8048818 <__printf_chk@plt>
 8048be6:	e8 c0 0e 00 00       	call   8049aab <read_line>
 8048beb:	89 04 24             	mov    %eax,(%esp)
 8048bee:	e8 19 01 00 00       	call   8048d0c <phase_6>
 8048bf3:	e8 3a 0d 00 00       	call   8049932 <phase_defused>
 8048bf8:	b8 00 00 00 00       	mov    $0x0,%eax
 8048bfd:	83 c4 18             	add    $0x18,%esp
 8048c00:	5b                   	pop    %ebx
 8048c01:	5e                   	pop    %esi
 8048c02:	89 ec                	mov    %ebp,%esp
 8048c04:	5d                   	pop    %ebp
 8048c05:	c3                   	ret    
 8048c06:	90                   	nop
 8048c07:	90                   	nop
 8048c08:	90                   	nop
 8048c09:	90                   	nop
 8048c0a:	90                   	nop
 8048c0b:	90                   	nop
 8048c0c:	90                   	nop
 8048c0d:	90                   	nop
 8048c0e:	90                   	nop
 8048c0f:	90                   	nop

08048c10 <func4>:
 8048c10:	55                   	push   %ebp
 8048c11:	89 e5                	mov    %esp,%ebp
 8048c13:	83 ec 18             	sub    $0x18,%esp
 8048c16:	89 5d f8             	mov    %ebx,-0x8(%ebp)
 8048c19:	89 75 fc             	mov    %esi,-0x4(%ebp)
 8048c1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
 8048c1f:	b8 01 00 00 00       	mov    $0x1,%eax
 8048c24:	83 fb 01             	cmp    $0x1,%ebx
 8048c27:	7e 1a                	jle    8048c43 <func4+0x33>
 8048c29:	8d 43 ff             	lea    -0x1(%ebx),%eax
 8048c2c:	89 04 24             	mov    %eax,(%esp)
 8048c2f:	e8 dc ff ff ff       	call   8048c10 <func4>
 8048c34:	89 c6                	mov    %eax,%esi
 8048c36:	83 eb 02             	sub    $0x2,%ebx
 8048c39:	89 1c 24             	mov    %ebx,(%esp)
 8048c3c:	e8 cf ff ff ff       	call   8048c10 <func4>
 8048c41:	01 f0                	add    %esi,%eax
 8048c43:	8b 5d f8             	mov    -0x8(%ebp),%ebx
 8048c46:	8b 75 fc             	mov    -0x4(%ebp),%esi
 8048c49:	89 ec                	mov    %ebp,%esp
 8048c4b:	5d                   	pop    %ebp
 8048c4c:	c3                   	ret    

08048c4d <fun7>:
 8048c4d:	55                   	push   %ebp
 8048c4e:	89 e5                	mov    %esp,%ebp
 8048c50:	53                   	push   %ebx
 8048c51:	83 ec 14             	sub    $0x14,%esp
 8048c54:	8b 55 08             	mov    0x8(%ebp),%edx
 8048c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 8048c5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 8048c5f:	85 d2                	test   %edx,%edx
 8048c61:	74 35                	je     8048c98 <fun7+0x4b>
 8048c63:	8b 1a                	mov    (%edx),%ebx
 8048c65:	39 cb                	cmp    %ecx,%ebx
 8048c67:	7e 13                	jle    8048c7c <fun7+0x2f>
 8048c69:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 8048c6d:	8b 42 04             	mov    0x4(%edx),%eax
 8048c70:	89 04 24             	mov    %eax,(%esp)
 8048c73:	e8 d5 ff ff ff       	call   8048c4d <fun7>
 8048c78:	01 c0                	add    %eax,%eax
 8048c7a:	eb 1c                	jmp    8048c98 <fun7+0x4b>
 8048c7c:	b8 00 00 00 00       	mov    $0x0,%eax
 8048c81:	39 cb                	cmp    %ecx,%ebx
 8048c83:	74 13                	je     8048c98 <fun7+0x4b>
 8048c85:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 8048c89:	8b 42 08             	mov    0x8(%edx),%eax
 8048c8c:	89 04 24             	mov    %eax,(%esp)
 8048c8f:	e8 b9 ff ff ff       	call   8048c4d <fun7>
 8048c94:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
 8048c98:	83 c4 14             	add    $0x14,%esp
 8048c9b:	5b                   	pop    %ebx
 8048c9c:	5d                   	pop    %ebp
 8048c9d:	c3                   	ret    

08048c9e <secret_phase>:
 8048c9e:	55                   	push   %ebp
 8048c9f:	89 e5                	mov    %esp,%ebp
 8048ca1:	53                   	push   %ebx
 8048ca2:	83 ec 14             	sub    $0x14,%esp
 8048ca5:	e8 01 0e 00 00       	call   8049aab <read_line>
 8048caa:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 8048cb1:	00 
 8048cb2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 8048cb9:	00 
 8048cba:	89 04 24             	mov    %eax,(%esp)
 8048cbd:	e8 d6 fb ff ff       	call   8048898 <strtol@plt>
 8048cc2:	89 c3                	mov    %eax,%ebx
 8048cc4:	8d 40 ff             	lea    -0x1(%eax),%eax
 8048cc7:	3d e8 03 00 00       	cmp    $0x3e8,%eax
 8048ccc:	76 05                	jbe    8048cd3 <secret_phase+0x35>
 8048cce:	e8 2f 0d 00 00       	call   8049a02 <explode_bomb>
 8048cd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
 8048cd7:	c7 04 24 b0 c5 04 08 	movl   $0x804c5b0,(%esp)
 8048cde:	e8 6a ff ff ff       	call   8048c4d <fun7>
 8048ce3:	83 f8 03             	cmp    $0x3,%eax
 8048ce6:	74 05                	je     8048ced <secret_phase+0x4f>
 8048ce8:	e8 15 0d 00 00       	call   8049a02 <explode_bomb>
 8048ced:	c7 44 24 04 30 9f 04 	movl   $0x8049f30,0x4(%esp)
 8048cf4:	08 
 8048cf5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8048cfc:	e8 17 fb ff ff       	call   8048818 <__printf_chk@plt>
 8048d01:	e8 2c 0c 00 00       	call   8049932 <phase_defused>
 8048d06:	83 c4 14             	add    $0x14,%esp
 8048d09:	5b                   	pop    %ebx
 8048d0a:	5d                   	pop    %ebp
 8048d0b:	c3                   	ret    

08048d0c <phase_6>:
 8048d0c:	55                   	push   %ebp
 8048d0d:	89 e5                	mov    %esp,%ebp
 8048d0f:	57                   	push   %edi
 8048d10:	56                   	push   %esi
 8048d11:	53                   	push   %ebx
 8048d12:	83 ec 5c             	sub    $0x5c,%esp
 8048d15:	8d 45 d0             	lea    -0x30(%ebp),%eax
 8048d18:	89 44 24 04          	mov    %eax,0x4(%esp)
 8048d1c:	8b 45 08             	mov    0x8(%ebp),%eax
 8048d1f:	89 04 24             	mov    %eax,(%esp)
 8048d22:	e8 35 0d 00 00       	call   8049a5c <read_six_numbers>
 8048d27:	be 00 00 00 00       	mov    $0x0,%esi
 8048d2c:	8d 7d d0             	lea    -0x30(%ebp),%edi
 8048d2f:	8b 04 b7             	mov    (%edi,%esi,4),%eax
 8048d32:	83 e8 01             	sub    $0x1,%eax
 8048d35:	83 f8 05             	cmp    $0x5,%eax
 8048d38:	76 05                	jbe    8048d3f <phase_6+0x33>
 8048d3a:	e8 c3 0c 00 00       	call   8049a02 <explode_bomb>
 8048d3f:	83 c6 01             	add    $0x1,%esi
 8048d42:	83 fe 06             	cmp    $0x6,%esi
 8048d45:	74 22                	je     8048d69 <phase_6+0x5d>
 8048d47:	8d 1c b7             	lea    (%edi,%esi,4),%ebx
 8048d4a:	89 75 b4             	mov    %esi,-0x4c(%ebp)
 8048d4d:	8b 44 b7 fc          	mov    -0x4(%edi,%esi,4),%eax
 8048d51:	3b 03                	cmp    (%ebx),%eax
 8048d53:	75 05                	jne    8048d5a <phase_6+0x4e>
 8048d55:	e8 a8 0c 00 00       	call   8049a02 <explode_bomb>
 8048d5a:	83 45 b4 01          	addl   $0x1,-0x4c(%ebp)
 8048d5e:	83 c3 04             	add    $0x4,%ebx
 8048d61:	83 7d b4 05          	cmpl   $0x5,-0x4c(%ebp)
 8048d65:	7e e6                	jle    8048d4d <phase_6+0x41>
 8048d67:	eb c6                	jmp    8048d2f <phase_6+0x23>
 8048d69:	bb 00 00 00 00       	mov    $0x0,%ebx
 8048d6e:	8d 7d d0             	lea    -0x30(%ebp),%edi
 8048d71:	eb 16                	jmp    8048d89 <phase_6+0x7d>
 8048d73:	8b 52 08             	mov    0x8(%edx),%edx
 8048d76:	83 c0 01             	add    $0x1,%eax
 8048d79:	39 c8                	cmp    %ecx,%eax
 8048d7b:	75 f6                	jne    8048d73 <phase_6+0x67>
 8048d7d:	89 54 b5 b8          	mov    %edx,-0x48(%ebp,%esi,4)
 8048d81:	83 c3 01             	add    $0x1,%ebx
 8048d84:	83 fb 06             	cmp    $0x6,%ebx
 8048d87:	74 16                	je     8048d9f <phase_6+0x93>
 8048d89:	89 de                	mov    %ebx,%esi
 8048d8b:	8b 0c 9f             	mov    (%edi,%ebx,4),%ecx
 8048d8e:	ba fc c4 04 08       	mov    $0x804c4fc,%edx
 8048d93:	b8 01 00 00 00       	mov    $0x1,%eax
 8048d98:	83 f9 01             	cmp    $0x1,%ecx
 8048d9b:	7f d6                	jg     8048d73 <phase_6+0x67>
 8048d9d:	eb de                	jmp    8048d7d <phase_6+0x71>
 8048d9f:	8b 5d b8             	mov    -0x48(%ebp),%ebx
 8048da2:	8b 45 bc             	mov    -0x44(%ebp),%eax
 8048da5:	89 43 08             	mov    %eax,0x8(%ebx)
 8048da8:	8b 55 c0             	mov    -0x40(%ebp),%edx
 8048dab:	89 50 08             	mov    %edx,0x8(%eax)
 8048dae:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 8048db1:	89 42 08             	mov    %eax,0x8(%edx)
 8048db4:	8b 55 c8             	mov    -0x38(%ebp),%edx
 8048db7:	89 50 08             	mov    %edx,0x8(%eax)
 8048dba:	8b 45 cc             	mov    -0x34(%ebp),%eax
 8048dbd:	89 42 08             	mov    %eax,0x8(%edx)
 8048dc0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
 8048dc7:	be 00 00 00 00       	mov    $0x0,%esi
 8048dcc:	8b 43 08             	mov    0x8(%ebx),%eax
 8048dcf:	8b 13                	mov    (%ebx),%edx
 8048dd1:	3b 10                	cmp    (%eax),%edx
 8048dd3:	7d 05                	jge    8048dda <phase_6+0xce>
 8048dd5:	e8 28 0c 00 00       	call   8049a02 <explode_bomb>
 8048dda:	8b 5b 08             	mov    0x8(%ebx),%ebx
 8048ddd:	83 c6 01             	add    $0x1,%esi
 8048de0:	83 fe 05             	cmp    $0x5,%esi
 8048de3:	75 e7                	jne    8048dcc <phase_6+0xc0>
 8048de5:	83 c4 5c             	add    $0x5c,%esp
 8048de8:	5b                   	pop    %ebx
 8048de9:	5e                   	pop    %esi
 8048dea:	5f                   	pop    %edi
 8048deb:	5d                   	pop    %ebp
 8048dec:	c3                   	ret    

08048ded <phase_2>:
 8048ded:	55                   	push   %ebp
 8048dee:	89 e5                	mov    %esp,%ebp
 8048df0:	56                   	push   %esi
 8048df1:	53                   	push   %ebx
 8048df2:	83 ec 30             	sub    $0x30,%esp
 8048df5:	8d 45 e0             	lea    -0x20(%ebp),%eax
 8048df8:	89 44 24 04          	mov    %eax,0x4(%esp)
 8048dfc:	8b 45 08             	mov    0x8(%ebp),%eax
 8048dff:	89 04 24             	mov    %eax,(%esp)
 8048e02:	e8 55 0c 00 00       	call   8049a5c <read_six_numbers>
 8048e07:	83 7d e0 01          	cmpl   $0x1,-0x20(%ebp)
 8048e0b:	74 05                	je     8048e12 <phase_2+0x25>
 8048e0d:	e8 f0 0b 00 00       	call   8049a02 <explode_bomb>
 8048e12:	bb 01 00 00 00       	mov    $0x1,%ebx
 8048e17:	8d 75 e0             	lea    -0x20(%ebp),%esi
 8048e1a:	89 d8                	mov    %ebx,%eax
 8048e1c:	83 c3 01             	add    $0x1,%ebx
 8048e1f:	89 da                	mov    %ebx,%edx
 8048e21:	0f af 54 86 fc       	imul   -0x4(%esi,%eax,4),%edx
 8048e26:	39 14 86             	cmp    %edx,(%esi,%eax,4)
 8048e29:	74 05                	je     8048e30 <phase_2+0x43>
 8048e2b:	e8 d2 0b 00 00       	call   8049a02 <explode_bomb>
 8048e30:	83 fb 06             	cmp    $0x6,%ebx
 8048e33:	75 e5                	jne    8048e1a <phase_2+0x2d>
 8048e35:	83 c4 30             	add    $0x30,%esp
 8048e38:	5b                   	pop    %ebx
 8048e39:	5e                   	pop    %esi
 8048e3a:	5d                   	pop    %ebp
 8048e3b:	c3                   	ret    

08048e3c <phase_5>:
 8048e3c:	55                   	push   %ebp
 8048e3d:	89 e5                	mov    %esp,%ebp
 8048e3f:	56                   	push   %esi
 8048e40:	53                   	push   %ebx
 8048e41:	83 ec 20             	sub    $0x20,%esp
 8048e44:	8d 45 f0             	lea    -0x10(%ebp),%eax
 8048e47:	89 44 24 0c          	mov    %eax,0xc(%esp)
 8048e4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 8048e4e:	89 44 24 08          	mov    %eax,0x8(%esp)
 8048e52:	c7 44 24 04 dc a1 04 	movl   $0x804a1dc,0x4(%esp)
 8048e59:	08 
 8048e5a:	8b 45 08             	mov    0x8(%ebp),%eax
 8048e5d:	89 04 24             	mov    %eax,(%esp)
 8048e60:	e8 a3 f9 ff ff       	call   8048808 <__isoc99_sscanf@plt>
 8048e65:	83 f8 01             	cmp    $0x1,%eax
 8048e68:	7f 05                	jg     8048e6f <phase_5+0x33>
 8048e6a:	e8 93 0b 00 00       	call   8049a02 <explode_bomb>
 8048e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8048e72:	83 e0 0f             	and    $0xf,%eax
 8048e75:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8048e78:	83 f8 0f             	cmp    $0xf,%eax
 8048e7b:	74 29                	je     8048ea6 <phase_5+0x6a>
 8048e7d:	b9 00 00 00 00       	mov    $0x0,%ecx
 8048e82:	ba 00 00 00 00       	mov    $0x0,%edx
 8048e87:	bb c0 9f 04 08       	mov    $0x8049fc0,%ebx
 8048e8c:	83 c2 01             	add    $0x1,%edx
 8048e8f:	8b 04 83             	mov    (%ebx,%eax,4),%eax
 8048e92:	01 c1                	add    %eax,%ecx
 8048e94:	83 f8 0f             	cmp    $0xf,%eax
 8048e97:	75 f3                	jne    8048e8c <phase_5+0x50>
 8048e99:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8048e9c:	83 fa 0a             	cmp    $0xa,%edx
 8048e9f:	75 05                	jne    8048ea6 <phase_5+0x6a>
 8048ea1:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
 8048ea4:	74 05                	je     8048eab <phase_5+0x6f>
 8048ea6:	e8 57 0b 00 00       	call   8049a02 <explode_bomb>
 8048eab:	83 c4 20             	add    $0x20,%esp
 8048eae:	5b                   	pop    %ebx
 8048eaf:	5e                   	pop    %esi
 8048eb0:	5d                   	pop    %ebp
 8048eb1:	c3                   	ret    

08048eb2 <phase_4>:
 8048eb2:	55                   	push   %ebp
 8048eb3:	89 e5                	mov    %esp,%ebp
 8048eb5:	83 ec 28             	sub    $0x28,%esp
 8048eb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 8048ebb:	89 44 24 08          	mov    %eax,0x8(%esp)
 8048ebf:	c7 44 24 04 8d 9f 04 	movl   $0x8049f8d,0x4(%esp)
 8048ec6:	08 
 8048ec7:	8b 45 08             	mov    0x8(%ebp),%eax
 8048eca:	89 04 24             	mov    %eax,(%esp)
 8048ecd:	e8 36 f9 ff ff       	call   8048808 <__isoc99_sscanf@plt>
 8048ed2:	83 f8 01             	cmp    $0x1,%eax
 8048ed5:	75 06                	jne    8048edd <phase_4+0x2b>
 8048ed7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8048edb:	7f 08                	jg     8048ee5 <phase_4+0x33>
 8048edd:	8d 76 00             	lea    0x0(%esi),%esi
 8048ee0:	e8 1d 0b 00 00       	call   8049a02 <explode_bomb>
 8048ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8048ee8:	89 04 24             	mov    %eax,(%esp)
 8048eeb:	e8 20 fd ff ff       	call   8048c10 <func4>
 8048ef0:	83 f8 37             	cmp    $0x37,%eax
 8048ef3:	74 05                	je     8048efa <phase_4+0x48>
 8048ef5:	e8 08 0b 00 00       	call   8049a02 <explode_bomb>
 8048efa:	c9                   	leave  
 8048efb:	90                   	nop
 8048efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 8048f00:	c3                   	ret    

08048f01 <phase_3>:
 8048f01:	55                   	push   %ebp
 8048f02:	89 e5                	mov    %esp,%ebp
 8048f04:	83 ec 38             	sub    $0x38,%esp
 8048f07:	8d 45 ec             	lea    -0x14(%ebp),%eax
 8048f0a:	89 44 24 10          	mov    %eax,0x10(%esp)
 8048f0e:	8d 45 f7             	lea    -0x9(%ebp),%eax
 8048f11:	89 44 24 0c          	mov    %eax,0xc(%esp)
 8048f15:	8d 45 f0             	lea    -0x10(%ebp),%eax
 8048f18:	89 44 24 08          	mov    %eax,0x8(%esp)
 8048f1c:	c7 44 24 04 87 9f 04 	movl   $0x8049f87,0x4(%esp)
 8048f23:	08 
 8048f24:	8b 45 08             	mov    0x8(%ebp),%eax
 8048f27:	89 04 24             	mov    %eax,(%esp)
 8048f2a:	e8 d9 f8 ff ff       	call   8048808 <__isoc99_sscanf@plt>
 8048f2f:	83 f8 02             	cmp    $0x2,%eax
 8048f32:	7f 05                	jg     8048f39 <phase_3+0x38>
 8048f34:	e8 c9 0a 00 00       	call   8049a02 <explode_bomb>
 8048f39:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
 8048f3d:	8d 76 00             	lea    0x0(%esi),%esi
 8048f40:	0f 87 f8 00 00 00    	ja     804903e <phase_3+0x13d>
 8048f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8048f49:	ff 24 85 a0 9f 04 08 	jmp    *0x8049fa0(,%eax,4)
 8048f50:	83 7d ec 7c          	cmpl   $0x7c,-0x14(%ebp)
 8048f54:	0f 84 f2 00 00 00    	je     804904c <phase_3+0x14b>
 8048f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 8048f60:	e8 9d 0a 00 00       	call   8049a02 <explode_bomb>
 8048f65:	b8 72 00 00 00       	mov    $0x72,%eax
 8048f6a:	e9 e9 00 00 00       	jmp    8049058 <phase_3+0x157>
 8048f6f:	81 7d ec ee 02 00 00 	cmpl   $0x2ee,-0x14(%ebp)
 8048f76:	0f 84 d7 00 00 00    	je     8049053 <phase_3+0x152>
 8048f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 8048f80:	e8 7d 0a 00 00       	call   8049a02 <explode_bomb>
 8048f85:	b8 77 00 00 00       	mov    $0x77,%eax
 8048f8a:	e9 c9 00 00 00       	jmp    8049058 <phase_3+0x157>
 8048f8f:	81 7d ec cf 02 00 00 	cmpl   $0x2cf,-0x14(%ebp)
 8048f96:	0f 84 b0 00 00 00    	je     804904c <phase_3+0x14b>
 8048f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 8048fa0:	e8 5d 0a 00 00       	call   8049a02 <explode_bomb>
 8048fa5:	b8 72 00 00 00       	mov    $0x72,%eax
 8048faa:	e9 a9 00 00 00       	jmp    8049058 <phase_3+0x157>
 8048faf:	81 7d ec 03 01 00 00 	cmpl   $0x103,-0x14(%ebp)
 8048fb6:	0f 84 97 00 00 00    	je     8049053 <phase_3+0x152>
 8048fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 8048fc0:	e8 3d 0a 00 00       	call   8049a02 <explode_bomb>
 8048fc5:	b8 77 00 00 00       	mov    $0x77,%eax
 8048fca:	e9 89 00 00 00       	jmp    8049058 <phase_3+0x157>
 8048fcf:	b8 6f 00 00 00       	mov    $0x6f,%eax
 8048fd4:	81 7d ec 96 02 00 00 	cmpl   $0x296,-0x14(%ebp)
 8048fdb:	74 7b                	je     8049058 <phase_3+0x157>
 8048fdd:	8d 76 00             	lea    0x0(%esi),%esi
 8048fe0:	e8 1d 0a 00 00       	call   8049a02 <explode_bomb>
 8048fe5:	b8 6f 00 00 00       	mov    $0x6f,%eax
 8048fea:	eb 6c                	jmp    8049058 <phase_3+0x157>
 8048fec:	b8 68 00 00 00       	mov    $0x68,%eax
 8048ff1:	81 7d ec de 02 00 00 	cmpl   $0x2de,-0x14(%ebp)
 8048ff8:	74 5e                	je     8049058 <phase_3+0x157>
 8048ffa:	e8 03 0a 00 00       	call   8049a02 <explode_bomb>
 8048fff:	b8 68 00 00 00       	mov    $0x68,%eax
 8049004:	eb 52                	jmp    8049058 <phase_3+0x157>
 8049006:	b8 67 00 00 00       	mov    $0x67,%eax
 804900b:	81 7d ec de 03 00 00 	cmpl   $0x3de,-0x14(%ebp)
 8049012:	74 44                	je     8049058 <phase_3+0x157>
 8049014:	e8 e9 09 00 00       	call   8049a02 <explode_bomb>
 8049019:	b8 67 00 00 00       	mov    $0x67,%eax
 804901e:	66 90                	xchg   %ax,%ax
 8049020:	eb 36                	jmp    8049058 <phase_3+0x157>
 8049022:	b8 71 00 00 00       	mov    $0x71,%eax
 8049027:	81 7d ec 83 00 00 00 	cmpl   $0x83,-0x14(%ebp)
 804902e:	66 90                	xchg   %ax,%ax
 8049030:	74 26                	je     8049058 <phase_3+0x157>
 8049032:	e8 cb 09 00 00       	call   8049a02 <explode_bomb>
 8049037:	b8 71 00 00 00       	mov    $0x71,%eax
 804903c:	eb 1a                	jmp    8049058 <phase_3+0x157>
 804903e:	66 90                	xchg   %ax,%ax
 8049040:	e8 bd 09 00 00       	call   8049a02 <explode_bomb>
 8049045:	b8 64 00 00 00       	mov    $0x64,%eax
 804904a:	eb 0c                	jmp    8049058 <phase_3+0x157>
 804904c:	b8 72 00 00 00       	mov    $0x72,%eax
 8049051:	eb 05                	jmp    8049058 <phase_3+0x157>
 8049053:	b8 77 00 00 00       	mov    $0x77,%eax
 8049058:	3a 45 f7             	cmp    -0x9(%ebp),%al
 804905b:	74 08                	je     8049065 <phase_3+0x164>
 804905d:	8d 76 00             	lea    0x0(%esi),%esi
 8049060:	e8 9d 09 00 00       	call   8049a02 <explode_bomb>
 8049065:	c9                   	leave  
 8049066:	c3                   	ret    

08049067 <phase_1>:
 8049067:	55                   	push   %ebp
 8049068:	89 e5                	mov    %esp,%ebp
 804906a:	83 ec 18             	sub    $0x18,%esp
 804906d:	c7 44 24 04 58 9f 04 	movl   $0x8049f58,0x4(%esp)
 8049074:	08 
 8049075:	8b 45 08             	mov    0x8(%ebp),%eax
 8049078:	89 04 24             	mov    %eax,(%esp)
 804907b:	e8 2b 00 00 00       	call   80490ab <strings_not_equal>
 8049080:	85 c0                	test   %eax,%eax
 8049082:	74 05                	je     8049089 <phase_1+0x22>
 8049084:	e8 79 09 00 00       	call   8049a02 <explode_bomb>
 8049089:	c9                   	leave  
 804908a:	c3                   	ret    
 804908b:	90                   	nop
 804908c:	90                   	nop
 804908d:	90                   	nop
 804908e:	90                   	nop
 804908f:	90                   	nop

08049090 <string_length>:
 8049090:	55                   	push   %ebp
 8049091:	89 e5                	mov    %esp,%ebp
 8049093:	8b 55 08             	mov    0x8(%ebp),%edx
 8049096:	b8 00 00 00 00       	mov    $0x0,%eax
 804909b:	80 3a 00             	cmpb   $0x0,(%edx)
 804909e:	74 09                	je     80490a9 <string_length+0x19>
 80490a0:	83 c0 01             	add    $0x1,%eax
 80490a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
 80490a7:	75 f7                	jne    80490a0 <string_length+0x10>
 80490a9:	5d                   	pop    %ebp
 80490aa:	c3                   	ret    

080490ab <strings_not_equal>:
 80490ab:	55                   	push   %ebp
 80490ac:	89 e5                	mov    %esp,%ebp
 80490ae:	57                   	push   %edi
 80490af:	56                   	push   %esi
 80490b0:	53                   	push   %ebx
 80490b1:	83 ec 04             	sub    $0x4,%esp
 80490b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
 80490b7:	8b 75 0c             	mov    0xc(%ebp),%esi
 80490ba:	89 1c 24             	mov    %ebx,(%esp)
 80490bd:	e8 ce ff ff ff       	call   8049090 <string_length>
 80490c2:	89 c7                	mov    %eax,%edi
 80490c4:	89 34 24             	mov    %esi,(%esp)
 80490c7:	e8 c4 ff ff ff       	call   8049090 <string_length>
 80490cc:	39 c7                	cmp    %eax,%edi
 80490ce:	75 29                	jne    80490f9 <strings_not_equal+0x4e>
 80490d0:	0f b6 13             	movzbl (%ebx),%edx
 80490d3:	84 d2                	test   %dl,%dl
 80490d5:	74 2b                	je     8049102 <strings_not_equal+0x57>
 80490d7:	b8 00 00 00 00       	mov    $0x0,%eax
 80490dc:	3a 16                	cmp    (%esi),%dl
 80490de:	74 0e                	je     80490ee <strings_not_equal+0x43>
 80490e0:	eb 17                	jmp    80490f9 <strings_not_equal+0x4e>
 80490e2:	0f b6 4c 06 01       	movzbl 0x1(%esi,%eax,1),%ecx
 80490e7:	83 c0 01             	add    $0x1,%eax
 80490ea:	38 ca                	cmp    %cl,%dl
 80490ec:	75 0b                	jne    80490f9 <strings_not_equal+0x4e>
 80490ee:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
 80490f3:	84 d2                	test   %dl,%dl
 80490f5:	75 eb                	jne    80490e2 <strings_not_equal+0x37>
 80490f7:	eb 09                	jmp    8049102 <strings_not_equal+0x57>
 80490f9:	b8 01 00 00 00       	mov    $0x1,%eax
 80490fe:	66 90                	xchg   %ax,%ax
 8049100:	eb 05                	jmp    8049107 <strings_not_equal+0x5c>
 8049102:	b8 00 00 00 00       	mov    $0x0,%eax
 8049107:	83 c4 04             	add    $0x4,%esp
 804910a:	5b                   	pop    %ebx
 804910b:	5e                   	pop    %esi
 804910c:	5f                   	pop    %edi
 804910d:	5d                   	pop    %ebp
 804910e:	c3                   	ret    

0804910f <invalid_phase>:
 804910f:	55                   	push   %ebp
 8049110:	89 e5                	mov    %esp,%ebp
 8049112:	83 ec 18             	sub    $0x18,%esp
 8049115:	8b 45 08             	mov    0x8(%ebp),%eax
 8049118:	89 44 24 08          	mov    %eax,0x8(%esp)
 804911c:	c7 44 24 04 00 a0 04 	movl   $0x804a000,0x4(%esp)
 8049123:	08 
 8049124:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 804912b:	e8 e8 f6 ff ff       	call   8048818 <__printf_chk@plt>
 8049130:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 8049137:	e8 5c f8 ff ff       	call   8048998 <exit@plt>

0804913c <writen>:
 804913c:	55                   	push   %ebp
 804913d:	89 e5                	mov    %esp,%ebp
 804913f:	57                   	push   %edi
 8049140:	56                   	push   %esi
 8049141:	53                   	push   %ebx
 8049142:	83 ec 1c             	sub    $0x1c,%esp
 8049145:	8b 7d 08             	mov    0x8(%ebp),%edi
 8049148:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 804914c:	74 38                	je     8049186 <writen+0x4a>
 804914e:	8b 75 0c             	mov    0xc(%ebp),%esi
 8049151:	8b 5d 10             	mov    0x10(%ebp),%ebx
 8049154:	89 5c 24 08          	mov    %ebx,0x8(%esp)
 8049158:	89 74 24 04          	mov    %esi,0x4(%esp)
 804915c:	89 3c 24             	mov    %edi,(%esp)
 804915f:	e8 e4 f6 ff ff       	call   8048848 <write@plt>
 8049164:	85 c0                	test   %eax,%eax
 8049166:	7f 16                	jg     804917e <writen+0x42>
 8049168:	e8 3b f6 ff ff       	call   80487a8 <__errno_location@plt>
 804916d:	83 38 04             	cmpl   $0x4,(%eax)
 8049170:	74 07                	je     8049179 <writen+0x3d>
 8049172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 8049177:	eb 10                	jmp    8049189 <writen+0x4d>
 8049179:	b8 00 00 00 00       	mov    $0x0,%eax
 804917e:	29 c3                	sub    %eax,%ebx
 8049180:	74 04                	je     8049186 <writen+0x4a>
 8049182:	01 c6                	add    %eax,%esi
 8049184:	eb ce                	jmp    8049154 <writen+0x18>
 8049186:	8b 45 10             	mov    0x10(%ebp),%eax
 8049189:	83 c4 1c             	add    $0x1c,%esp
 804918c:	5b                   	pop    %ebx
 804918d:	5e                   	pop    %esi
 804918e:	5f                   	pop    %edi
 804918f:	5d                   	pop    %ebp
 8049190:	c3                   	ret    

08049191 <blank_line>:
 8049191:	55                   	push   %ebp
 8049192:	89 e5                	mov    %esp,%ebp
 8049194:	56                   	push   %esi
 8049195:	53                   	push   %ebx
 8049196:	8b 75 08             	mov    0x8(%ebp),%esi
 8049199:	eb 1b                	jmp    80491b6 <blank_line+0x25>
 804919b:	e8 38 f7 ff ff       	call   80488d8 <__ctype_b_loc@plt>
 80491a0:	0f be db             	movsbl %bl,%ebx
 80491a3:	8b 00                	mov    (%eax),%eax
 80491a5:	f6 44 58 01 20       	testb  $0x20,0x1(%eax,%ebx,2)
 80491aa:	75 07                	jne    80491b3 <blank_line+0x22>
 80491ac:	b8 00 00 00 00       	mov    $0x0,%eax
 80491b1:	eb 0f                	jmp    80491c2 <blank_line+0x31>
 80491b3:	83 c6 01             	add    $0x1,%esi
 80491b6:	0f b6 1e             	movzbl (%esi),%ebx
 80491b9:	84 db                	test   %bl,%bl
 80491bb:	75 de                	jne    804919b <blank_line+0xa>
 80491bd:	b8 01 00 00 00       	mov    $0x1,%eax
 80491c2:	5b                   	pop    %ebx
 80491c3:	5e                   	pop    %esi
 80491c4:	5d                   	pop    %ebp
 80491c5:	c3                   	ret    

080491c6 <skip>:
 80491c6:	55                   	push   %ebp
 80491c7:	89 e5                	mov    %esp,%ebp
 80491c9:	53                   	push   %ebx
 80491ca:	83 ec 14             	sub    $0x14,%esp
 80491cd:	a1 f0 c5 04 08       	mov    0x804c5f0,%eax
 80491d2:	89 44 24 08          	mov    %eax,0x8(%esp)
 80491d6:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
 80491dd:	00 
 80491de:	a1 ec c5 04 08       	mov    0x804c5ec,%eax
 80491e3:	8d 04 80             	lea    (%eax,%eax,4),%eax
 80491e6:	c1 e0 04             	shl    $0x4,%eax
 80491e9:	05 00 c6 04 08       	add    $0x804c600,%eax
 80491ee:	89 04 24             	mov    %eax,(%esp)
 80491f1:	e8 62 f6 ff ff       	call   8048858 <fgets@plt>
 80491f6:	89 c3                	mov    %eax,%ebx
 80491f8:	85 c0                	test   %eax,%eax
 80491fa:	74 0c                	je     8049208 <skip+0x42>
 80491fc:	89 04 24             	mov    %eax,(%esp)
 80491ff:	e8 8d ff ff ff       	call   8049191 <blank_line>
 8049204:	85 c0                	test   %eax,%eax
 8049206:	75 c5                	jne    80491cd <skip+0x7>
 8049208:	89 d8                	mov    %ebx,%eax
 804920a:	83 c4 14             	add    $0x14,%esp
 804920d:	5b                   	pop    %ebx
 804920e:	5d                   	pop    %ebp
 804920f:	c3                   	ret    

08049210 <sig_handler>:
 8049210:	55                   	push   %ebp
 8049211:	89 e5                	mov    %esp,%ebp
 8049213:	83 ec 18             	sub    $0x18,%esp
 8049216:	c7 44 24 04 40 a2 04 	movl   $0x804a240,0x4(%esp)
 804921d:	08 
 804921e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049225:	e8 ee f5 ff ff       	call   8048818 <__printf_chk@plt>
 804922a:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
 8049231:	e8 22 f7 ff ff       	call   8048958 <sleep@plt>
 8049236:	c7 44 24 04 11 a0 04 	movl   $0x804a011,0x4(%esp)
 804923d:	08 
 804923e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049245:	e8 ce f5 ff ff       	call   8048818 <__printf_chk@plt>
 804924a:	a1 e0 c5 04 08       	mov    0x804c5e0,%eax
 804924f:	89 04 24             	mov    %eax,(%esp)
 8049252:	e8 61 f6 ff ff       	call   80488b8 <fflush@plt>
 8049257:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 804925e:	e8 f5 f6 ff ff       	call   8048958 <sleep@plt>
 8049263:	c7 44 24 04 19 a0 04 	movl   $0x804a019,0x4(%esp)
 804926a:	08 
 804926b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049272:	e8 a1 f5 ff ff       	call   8048818 <__printf_chk@plt>
 8049277:	c7 04 24 10 00 00 00 	movl   $0x10,(%esp)
 804927e:	e8 15 f7 ff ff       	call   8048998 <exit@plt>

08049283 <send_msg_2>:
 8049283:	55                   	push   %ebp
 8049284:	89 e5                	mov    %esp,%ebp
 8049286:	57                   	push   %edi
 8049287:	56                   	push   %esi
 8049288:	53                   	push   %ebx
 8049289:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
 804928f:	65 a1 14 00 00 00    	mov    %gs:0x14,%eax
 8049295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 8049298:	31 c0                	xor    %eax,%eax
 804929a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 80492a1:	e8 52 f6 ff ff       	call   80488f8 <dup@plt>
 80492a6:	89 45 80             	mov    %eax,-0x80(%ebp)
 80492a9:	83 f8 ff             	cmp    $0xffffffff,%eax
 80492ac:	75 20                	jne    80492ce <send_msg_2+0x4b>
 80492ae:	c7 44 24 04 22 a0 04 	movl   $0x804a022,0x4(%esp)
 80492b5:	08 
 80492b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 80492bd:	e8 56 f5 ff ff       	call   8048818 <__printf_chk@plt>
 80492c2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 80492c9:	e8 ca f6 ff ff       	call   8048998 <exit@plt>
 80492ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 80492d5:	e8 4e f6 ff ff       	call   8048928 <close@plt>
 80492da:	83 f8 ff             	cmp    $0xffffffff,%eax
 80492dd:	75 20                	jne    80492ff <send_msg_2+0x7c>
 80492df:	c7 44 24 04 37 a0 04 	movl   $0x804a037,0x4(%esp)
 80492e6:	08 
 80492e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 80492ee:	e8 25 f5 ff ff       	call   8048818 <__printf_chk@plt>
 80492f3:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 80492fa:	e8 99 f6 ff ff       	call   8048998 <exit@plt>
 80492ff:	e8 84 f5 ff ff       	call   8048888 <tmpfile@plt>
 8049304:	89 45 84             	mov    %eax,-0x7c(%ebp)
 8049307:	85 c0                	test   %eax,%eax
 8049309:	75 20                	jne    804932b <send_msg_2+0xa8>
 804930b:	c7 44 24 04 4b a0 04 	movl   $0x804a04b,0x4(%esp)
 8049312:	08 
 8049313:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 804931a:	e8 f9 f4 ff ff       	call   8048818 <__printf_chk@plt>
 804931f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 8049326:	e8 6d f6 ff ff       	call   8048998 <exit@plt>
 804932b:	8b 7d 84             	mov    -0x7c(%ebp),%edi
 804932e:	c7 44 24 08 61 a0 04 	movl   $0x804a061,0x8(%esp)
 8049335:	08 
 8049336:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 804933d:	00 
 804933e:	89 3c 24             	mov    %edi,(%esp)
 8049341:	e8 82 f4 ff ff       	call   80487c8 <__fprintf_chk@plt>
 8049346:	c7 44 24 08 b6 a1 04 	movl   $0x804a1b6,0x8(%esp)
 804934d:	08 
 804934e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 8049355:	00 
 8049356:	8b 45 84             	mov    -0x7c(%ebp),%eax
 8049359:	89 04 24             	mov    %eax,(%esp)
 804935c:	e8 67 f4 ff ff       	call   80487c8 <__fprintf_chk@plt>
 8049361:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 8049368:	e8 cb f5 ff ff       	call   8048938 <cuserid@plt>
 804936d:	85 c0                	test   %eax,%eax
 804936f:	75 15                	jne    8049386 <send_msg_2+0x103>
 8049371:	8d 45 94             	lea    -0x6c(%ebp),%eax
 8049374:	c7 00 6e 6f 62 6f    	movl   $0x6f626f6e,(%eax)
 804937a:	66 c7 40 04 64 79    	movw   $0x7964,0x4(%eax)
 8049380:	c6 40 06 00          	movb   $0x0,0x6(%eax)
 8049384:	eb 17                	jmp    804939d <send_msg_2+0x11a>
 8049386:	c7 44 24 08 50 00 00 	movl   $0x50,0x8(%esp)
 804938d:	00 
 804938e:	89 44 24 04          	mov    %eax,0x4(%esp)
 8049392:	8d 45 94             	lea    -0x6c(%ebp),%eax
 8049395:	89 04 24             	mov    %eax,(%esp)
 8049398:	e8 7b f5 ff ff       	call   8048918 <__strcpy_chk@plt>
 804939d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 80493a1:	b8 7d a0 04 08       	mov    $0x804a07d,%eax
 80493a6:	ba 86 a0 04 08       	mov    $0x804a086,%edx
 80493ab:	0f 45 c2             	cmovne %edx,%eax
 80493ae:	8b 15 ec c5 04 08    	mov    0x804c5ec,%edx
 80493b4:	89 54 24 1c          	mov    %edx,0x1c(%esp)
 80493b8:	89 44 24 18          	mov    %eax,0x18(%esp)
 80493bc:	8d 45 94             	lea    -0x6c(%ebp),%eax
 80493bf:	89 44 24 14          	mov    %eax,0x14(%esp)
 80493c3:	a1 a0 c0 04 08       	mov    0x804c0a0,%eax
 80493c8:	89 44 24 10          	mov    %eax,0x10(%esp)
 80493cc:	c7 44 24 0c c0 c0 04 	movl   $0x804c0c0,0xc(%esp)
 80493d3:	08 
 80493d4:	c7 44 24 08 8e a0 04 	movl   $0x804a08e,0x8(%esp)
 80493db:	08 
 80493dc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 80493e3:	00 
 80493e4:	89 3c 24             	mov    %edi,(%esp)
 80493e7:	e8 dc f3 ff ff       	call   80487c8 <__fprintf_chk@plt>
 80493ec:	83 3d ec c5 04 08 00 	cmpl   $0x0,0x804c5ec
 80493f3:	7e 50                	jle    8049445 <send_msg_2+0x1c2>
 80493f5:	be 00 c6 04 08       	mov    $0x804c600,%esi
 80493fa:	bb 00 00 00 00       	mov    $0x0,%ebx
 80493ff:	83 c3 01             	add    $0x1,%ebx
 8049402:	89 74 24 1c          	mov    %esi,0x1c(%esp)
 8049406:	89 5c 24 18          	mov    %ebx,0x18(%esp)
 804940a:	8d 45 94             	lea    -0x6c(%ebp),%eax
 804940d:	89 44 24 14          	mov    %eax,0x14(%esp)
 8049411:	a1 a0 c0 04 08       	mov    0x804c0a0,%eax
 8049416:	89 44 24 10          	mov    %eax,0x10(%esp)
 804941a:	c7 44 24 0c c0 c0 04 	movl   $0x804c0c0,0xc(%esp)
 8049421:	08 
 8049422:	c7 44 24 08 aa a0 04 	movl   $0x804a0aa,0x8(%esp)
 8049429:	08 
 804942a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 8049431:	00 
 8049432:	89 3c 24             	mov    %edi,(%esp)
 8049435:	e8 8e f3 ff ff       	call   80487c8 <__fprintf_chk@plt>
 804943a:	83 c6 50             	add    $0x50,%esi
 804943d:	39 1d ec c5 04 08    	cmp    %ebx,0x804c5ec
 8049443:	7f ba                	jg     80493ff <send_msg_2+0x17c>
 8049445:	8b 45 84             	mov    -0x7c(%ebp),%eax
 8049448:	89 04 24             	mov    %eax,(%esp)
 804944b:	e8 a8 f3 ff ff       	call   80487f8 <rewind@plt>
 8049450:	c7 44 24 18 c6 a0 04 	movl   $0x804a0c6,0x18(%esp)
 8049457:	08 
 8049458:	c7 44 24 14 d0 a0 04 	movl   $0x804a0d0,0x14(%esp)
 804945f:	08 
 8049460:	c7 44 24 10 d5 a0 04 	movl   $0x804a0d5,0x10(%esp)
 8049467:	08 
 8049468:	c7 44 24 0c ec a0 04 	movl   $0x804a0ec,0xc(%esp)
 804946f:	08 
 8049470:	c7 44 24 08 50 00 00 	movl   $0x50,0x8(%esp)
 8049477:	00 
 8049478:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 804947f:	00 
 8049480:	c7 04 24 40 cc 04 08 	movl   $0x804cc40,(%esp)
 8049487:	e8 dc f4 ff ff       	call   8048968 <__sprintf_chk@plt>
 804948c:	c7 04 24 40 cc 04 08 	movl   $0x804cc40,(%esp)
 8049493:	e8 a0 f3 ff ff       	call   8048838 <system@plt>
 8049498:	85 c0                	test   %eax,%eax
 804949a:	74 20                	je     80494bc <send_msg_2+0x239>
 804949c:	c7 44 24 04 f5 a0 04 	movl   $0x804a0f5,0x4(%esp)
 80494a3:	08 
 80494a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 80494ab:	e8 68 f3 ff ff       	call   8048818 <__printf_chk@plt>
 80494b0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 80494b7:	e8 dc f4 ff ff       	call   8048998 <exit@plt>
 80494bc:	8b 45 84             	mov    -0x7c(%ebp),%eax
 80494bf:	89 04 24             	mov    %eax,(%esp)
 80494c2:	e8 21 f4 ff ff       	call   80488e8 <fclose@plt>
 80494c7:	85 c0                	test   %eax,%eax
 80494c9:	74 20                	je     80494eb <send_msg_2+0x268>
 80494cb:	c7 44 24 04 10 a1 04 	movl   $0x804a110,0x4(%esp)
 80494d2:	08 
 80494d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 80494da:	e8 39 f3 ff ff       	call   8048818 <__printf_chk@plt>
 80494df:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 80494e6:	e8 ad f4 ff ff       	call   8048998 <exit@plt>
 80494eb:	8b 45 80             	mov    -0x80(%ebp),%eax
 80494ee:	89 04 24             	mov    %eax,(%esp)
 80494f1:	e8 02 f4 ff ff       	call   80488f8 <dup@plt>
 80494f6:	85 c0                	test   %eax,%eax
 80494f8:	74 20                	je     804951a <send_msg_2+0x297>
 80494fa:	c7 44 24 04 2a a1 04 	movl   $0x804a12a,0x4(%esp)
 8049501:	08 
 8049502:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049509:	e8 0a f3 ff ff       	call   8048818 <__printf_chk@plt>
 804950e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 8049515:	e8 7e f4 ff ff       	call   8048998 <exit@plt>
 804951a:	8b 45 80             	mov    -0x80(%ebp),%eax
 804951d:	89 04 24             	mov    %eax,(%esp)
 8049520:	e8 03 f4 ff ff       	call   8048928 <close@plt>
 8049525:	85 c0                	test   %eax,%eax
 8049527:	74 20                	je     8049549 <send_msg_2+0x2c6>
 8049529:	c7 44 24 04 46 a1 04 	movl   $0x804a146,0x4(%esp)
 8049530:	08 
 8049531:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049538:	e8 db f2 ff ff       	call   8048818 <__printf_chk@plt>
 804953d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 8049544:	e8 4f f4 ff ff       	call   8048998 <exit@plt>
 8049549:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 804954c:	65 33 05 14 00 00 00 	xor    %gs:0x14,%eax
 8049553:	74 05                	je     804955a <send_msg_2+0x2d7>
 8049555:	e8 ee f3 ff ff       	call   8048948 <__stack_chk_fail@plt>
 804955a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
 8049560:	5b                   	pop    %ebx
 8049561:	5e                   	pop    %esi
 8049562:	5f                   	pop    %edi
 8049563:	5d                   	pop    %ebp
 8049564:	c3                   	ret    

08049565 <send_msg>:
 8049565:	55                   	push   %ebp
 8049566:	89 e5                	mov    %esp,%ebp
 8049568:	57                   	push   %edi
 8049569:	56                   	push   %esi
 804956a:	53                   	push   %ebx
 804956b:	81 ec bc 24 00 00    	sub    $0x24bc,%esp
 8049571:	65 a1 14 00 00 00    	mov    %gs:0x14,%eax
 8049577:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 804957a:	31 c0                	xor    %eax,%eax
 804957c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
 8049583:	00 
 8049584:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 804958b:	00 
 804958c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 8049593:	e8 30 f3 ff ff       	call   80488c8 <socket@plt>
 8049598:	89 85 74 db ff ff    	mov    %eax,-0x248c(%ebp)
 804959e:	85 c0                	test   %eax,%eax
 80495a0:	79 3f                	jns    80495e1 <send_msg+0x7c>
 80495a2:	c7 44 24 0c 5e a1 04 	movl   $0x804a15e,0xc(%esp)
 80495a9:	08 
 80495aa:	c7 44 24 08 01 9e 04 	movl   $0x8049e01,0x8(%esp)
 80495b1:	08 
 80495b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 80495b9:	00 
 80495ba:	a1 e0 c5 04 08       	mov    0x804c5e0,%eax
 80495bf:	89 04 24             	mov    %eax,(%esp)
 80495c2:	e8 01 f2 ff ff       	call   80487c8 <__fprintf_chk@plt>
 80495c7:	8b 8d 74 db ff ff    	mov    -0x248c(%ebp),%ecx
 80495cd:	89 0c 24             	mov    %ecx,(%esp)
 80495d0:	e8 53 f3 ff ff       	call   8048928 <close@plt>
 80495d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 80495dc:	e8 b7 f3 ff ff       	call   8048998 <exit@plt>
 80495e1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 80495e4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
 80495eb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
 80495f2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
 80495f9:	66 c7 45 d4 02 00    	movw   $0x2,-0x2c(%ebp)
 80495ff:	66 c7 45 d6 c4 92    	movw   $0x92c4,-0x2a(%ebp)
 8049605:	8d 45 d8             	lea    -0x28(%ebp),%eax
 8049608:	89 44 24 08          	mov    %eax,0x8(%esp)
 804960c:	c7 44 24 04 6b a1 04 	movl   $0x804a16b,0x4(%esp)
 8049613:	08 
 8049614:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 804961b:	e8 88 f2 ff ff       	call   80488a8 <inet_pton@plt>
 8049620:	85 c0                	test   %eax,%eax
 8049622:	79 48                	jns    804966c <send_msg+0x107>
 8049624:	c7 44 24 0c 95 a1 04 	movl   $0x804a195,0xc(%esp)
 804962b:	08 
 804962c:	c7 44 24 08 01 9e 04 	movl   $0x8049e01,0x8(%esp)
 8049633:	08 
 8049634:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 804963b:	00 
 804963c:	a1 e0 c5 04 08       	mov    0x804c5e0,%eax
 8049641:	89 04 24             	mov    %eax,(%esp)
 8049644:	e8 7f f1 ff ff       	call   80487c8 <__fprintf_chk@plt>
 8049649:	83 bd 74 db ff ff 00 	cmpl   $0x0,-0x248c(%ebp)
 8049650:	74 0e                	je     8049660 <send_msg+0xfb>
 8049652:	8b 85 74 db ff ff    	mov    -0x248c(%ebp),%eax
 8049658:	89 04 24             	mov    %eax,(%esp)
 804965b:	e8 c8 f2 ff ff       	call   8048928 <close@plt>
 8049660:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049667:	e8 2c f3 ff ff       	call   8048998 <exit@plt>
 804966c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 8049673:	00 
 8049674:	8d 45 d4             	lea    -0x2c(%ebp),%eax
 8049677:	89 44 24 04          	mov    %eax,0x4(%esp)
 804967b:	8b 8d 74 db ff ff    	mov    -0x248c(%ebp),%ecx
 8049681:	89 0c 24             	mov    %ecx,(%esp)
 8049684:	e8 2f f1 ff ff       	call   80487b8 <connect@plt>
 8049689:	85 c0                	test   %eax,%eax
 804968b:	79 48                	jns    80496d5 <send_msg+0x170>
 804968d:	c7 44 24 0c 7a a1 04 	movl   $0x804a17a,0xc(%esp)
 8049694:	08 
 8049695:	c7 44 24 08 01 9e 04 	movl   $0x8049e01,0x8(%esp)
 804969c:	08 
 804969d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 80496a4:	00 
 80496a5:	a1 e0 c5 04 08       	mov    0x804c5e0,%eax
 80496aa:	89 04 24             	mov    %eax,(%esp)
 80496ad:	e8 16 f1 ff ff       	call   80487c8 <__fprintf_chk@plt>
 80496b2:	83 bd 74 db ff ff 00 	cmpl   $0x0,-0x248c(%ebp)
 80496b9:	74 0e                	je     80496c9 <send_msg+0x164>
 80496bb:	8b 85 74 db ff ff    	mov    -0x248c(%ebp),%eax
 80496c1:	89 04 24             	mov    %eax,(%esp)
 80496c4:	e8 5f f2 ff ff       	call   8048928 <close@plt>
 80496c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 80496d0:	e8 c3 f2 ff ff       	call   8048998 <exit@plt>
 80496d5:	8d b5 84 fb ff ff    	lea    -0x47c(%ebp),%esi
 80496db:	c7 44 24 0c 61 a0 04 	movl   $0x804a061,0xc(%esp)
 80496e2:	08 
 80496e3:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
 80496ea:	00 
 80496eb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 80496f2:	00 
 80496f3:	89 34 24             	mov    %esi,(%esp)
 80496f6:	e8 6d f2 ff ff       	call   8048968 <__sprintf_chk@plt>
 80496fb:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
 8049702:	00 
 8049703:	89 74 24 04          	mov    %esi,0x4(%esp)
 8049707:	8d 8d 84 db ff ff    	lea    -0x247c(%ebp),%ecx
 804970d:	89 0c 24             	mov    %ecx,(%esp)
 8049710:	e8 63 f1 ff ff       	call   8048878 <__strcat_chk@plt>
 8049715:	c7 44 24 0c b6 a1 04 	movl   $0x804a1b6,0xc(%esp)
 804971c:	08 
 804971d:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
 8049724:	00 
 8049725:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 804972c:	00 
 804972d:	89 34 24             	mov    %esi,(%esp)
 8049730:	e8 33 f2 ff ff       	call   8048968 <__sprintf_chk@plt>
 8049735:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
 804973c:	00 
 804973d:	89 74 24 04          	mov    %esi,0x4(%esp)
 8049741:	8d 85 84 db ff ff    	lea    -0x247c(%ebp),%eax
 8049747:	89 04 24             	mov    %eax,(%esp)
 804974a:	e8 29 f1 ff ff       	call   8048878 <__strcat_chk@plt>
 804974f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 8049756:	e8 dd f1 ff ff       	call   8048938 <cuserid@plt>
 804975b:	85 c0                	test   %eax,%eax
 804975d:	75 15                	jne    8049774 <send_msg+0x20f>
 804975f:	8d 45 84             	lea    -0x7c(%ebp),%eax
 8049762:	c7 00 6e 6f 62 6f    	movl   $0x6f626f6e,(%eax)
 8049768:	66 c7 40 04 64 79    	movw   $0x7964,0x4(%eax)
 804976e:	c6 40 06 00          	movb   $0x0,0x6(%eax)
 8049772:	eb 17                	jmp    804978b <send_msg+0x226>
 8049774:	c7 44 24 08 50 00 00 	movl   $0x50,0x8(%esp)
 804977b:	00 
 804977c:	89 44 24 04          	mov    %eax,0x4(%esp)
 8049780:	8d 45 84             	lea    -0x7c(%ebp),%eax
 8049783:	89 04 24             	mov    %eax,(%esp)
 8049786:	e8 8d f1 ff ff       	call   8048918 <__strcpy_chk@plt>
 804978b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 804978f:	b8 7d a0 04 08       	mov    $0x804a07d,%eax
 8049794:	ba 86 a0 04 08       	mov    $0x804a086,%edx
 8049799:	0f 45 c2             	cmovne %edx,%eax
 804979c:	8b 15 ec c5 04 08    	mov    0x804c5ec,%edx
 80497a2:	89 54 24 20          	mov    %edx,0x20(%esp)
 80497a6:	89 44 24 1c          	mov    %eax,0x1c(%esp)
 80497aa:	8d 45 84             	lea    -0x7c(%ebp),%eax
 80497ad:	89 44 24 18          	mov    %eax,0x18(%esp)
 80497b1:	a1 a0 c0 04 08       	mov    0x804c0a0,%eax
 80497b6:	89 44 24 14          	mov    %eax,0x14(%esp)
 80497ba:	c7 44 24 10 c0 c0 04 	movl   $0x804c0c0,0x10(%esp)
 80497c1:	08 
 80497c2:	c7 44 24 0c 8e a0 04 	movl   $0x804a08e,0xc(%esp)
 80497c9:	08 
 80497ca:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
 80497d1:	00 
 80497d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 80497d9:	00 
 80497da:	89 34 24             	mov    %esi,(%esp)
 80497dd:	e8 86 f1 ff ff       	call   8048968 <__sprintf_chk@plt>
 80497e2:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
 80497e9:	00 
 80497ea:	89 74 24 04          	mov    %esi,0x4(%esp)
 80497ee:	8d 8d 84 db ff ff    	lea    -0x247c(%ebp),%ecx
 80497f4:	89 0c 24             	mov    %ecx,(%esp)
 80497f7:	e8 7c f0 ff ff       	call   8048878 <__strcat_chk@plt>
 80497fc:	83 3d ec c5 04 08 00 	cmpl   $0x0,0x804c5ec
 8049803:	7e 72                	jle    8049877 <send_msg+0x312>
 8049805:	bf 00 c6 04 08       	mov    $0x804c600,%edi
 804980a:	bb 00 00 00 00       	mov    $0x0,%ebx
 804980f:	83 c3 01             	add    $0x1,%ebx
 8049812:	89 7c 24 20          	mov    %edi,0x20(%esp)
 8049816:	89 5c 24 1c          	mov    %ebx,0x1c(%esp)
 804981a:	8d 45 84             	lea    -0x7c(%ebp),%eax
 804981d:	89 44 24 18          	mov    %eax,0x18(%esp)
 8049821:	a1 a0 c0 04 08       	mov    0x804c0a0,%eax
 8049826:	89 44 24 14          	mov    %eax,0x14(%esp)
 804982a:	c7 44 24 10 c0 c0 04 	movl   $0x804c0c0,0x10(%esp)
 8049831:	08 
 8049832:	c7 44 24 0c aa a0 04 	movl   $0x804a0aa,0xc(%esp)
 8049839:	08 
 804983a:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
 8049841:	00 
 8049842:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 8049849:	00 
 804984a:	89 34 24             	mov    %esi,(%esp)
 804984d:	e8 16 f1 ff ff       	call   8048968 <__sprintf_chk@plt>
 8049852:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
 8049859:	00 
 804985a:	89 74 24 04          	mov    %esi,0x4(%esp)
 804985e:	8d 8d 84 db ff ff    	lea    -0x247c(%ebp),%ecx
 8049864:	89 0c 24             	mov    %ecx,(%esp)
 8049867:	e8 0c f0 ff ff       	call   8048878 <__strcat_chk@plt>
 804986c:	83 c7 50             	add    $0x50,%edi
 804986f:	39 1d ec c5 04 08    	cmp    %ebx,0x804c5ec
 8049875:	7f 98                	jg     804980f <send_msg+0x2aa>
 8049877:	8d 9d 84 db ff ff    	lea    -0x247c(%ebp),%ebx
 804987d:	be ff ff ff ff       	mov    $0xffffffff,%esi
 8049882:	89 df                	mov    %ebx,%edi
 8049884:	89 f1                	mov    %esi,%ecx
 8049886:	b8 00 00 00 00       	mov    $0x0,%eax
 804988b:	f2 ae                	repnz scas %es:(%edi),%al
 804988d:	f7 d1                	not    %ecx
 804988f:	83 e9 01             	sub    $0x1,%ecx
 8049892:	89 4c 24 08          	mov    %ecx,0x8(%esp)
 8049896:	89 5c 24 04          	mov    %ebx,0x4(%esp)
 804989a:	8b 8d 74 db ff ff    	mov    -0x248c(%ebp),%ecx
 80498a0:	89 0c 24             	mov    %ecx,(%esp)
 80498a3:	e8 94 f8 ff ff       	call   804913c <writen>
 80498a8:	89 c2                	mov    %eax,%edx
 80498aa:	89 df                	mov    %ebx,%edi
 80498ac:	89 f1                	mov    %esi,%ecx
 80498ae:	b8 00 00 00 00       	mov    $0x0,%eax
 80498b3:	f2 ae                	repnz scas %es:(%edi),%al
 80498b5:	89 ce                	mov    %ecx,%esi
 80498b7:	f7 d6                	not    %esi
 80498b9:	83 ee 01             	sub    $0x1,%esi
 80498bc:	39 f2                	cmp    %esi,%edx
 80498be:	73 48                	jae    8049908 <send_msg+0x3a3>
 80498c0:	c7 44 24 0c 88 a1 04 	movl   $0x804a188,0xc(%esp)
 80498c7:	08 
 80498c8:	c7 44 24 08 01 9e 04 	movl   $0x8049e01,0x8(%esp)
 80498cf:	08 
 80498d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 80498d7:	00 
 80498d8:	a1 e0 c5 04 08       	mov    0x804c5e0,%eax
 80498dd:	89 04 24             	mov    %eax,(%esp)
 80498e0:	e8 e3 ee ff ff       	call   80487c8 <__fprintf_chk@plt>
 80498e5:	83 bd 74 db ff ff 00 	cmpl   $0x0,-0x248c(%ebp)
 80498ec:	74 0e                	je     80498fc <send_msg+0x397>
 80498ee:	8b 85 74 db ff ff    	mov    -0x248c(%ebp),%eax
 80498f4:	89 04 24             	mov    %eax,(%esp)
 80498f7:	e8 2c f0 ff ff       	call   8048928 <close@plt>
 80498fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049903:	e8 90 f0 ff ff       	call   8048998 <exit@plt>
 8049908:	8b 8d 74 db ff ff    	mov    -0x248c(%ebp),%ecx
 804990e:	89 0c 24             	mov    %ecx,(%esp)
 8049911:	e8 12 f0 ff ff       	call   8048928 <close@plt>
 8049916:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8049919:	65 33 05 14 00 00 00 	xor    %gs:0x14,%eax
 8049920:	74 05                	je     8049927 <send_msg+0x3c2>
 8049922:	e8 21 f0 ff ff       	call   8048948 <__stack_chk_fail@plt>
 8049927:	81 c4 bc 24 00 00    	add    $0x24bc,%esp
 804992d:	5b                   	pop    %ebx
 804992e:	5e                   	pop    %esi
 804992f:	5f                   	pop    %edi
 8049930:	5d                   	pop    %ebp
 8049931:	c3                   	ret    

08049932 <phase_defused>:
 8049932:	55                   	push   %ebp
 8049933:	89 e5                	mov    %esp,%ebp
 8049935:	83 ec 78             	sub    $0x78,%esp
 8049938:	65 a1 14 00 00 00    	mov    %gs:0x14,%eax
 804993e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8049941:	31 c0                	xor    %eax,%eax
 8049943:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 804994a:	e8 16 fc ff ff       	call   8049565 <send_msg>
 804994f:	83 3d ec c5 04 08 06 	cmpl   $0x6,0x804c5ec
 8049956:	0f 85 93 00 00 00    	jne    80499ef <phase_defused+0xbd>
 804995c:	8d 45 a4             	lea    -0x5c(%ebp),%eax
 804995f:	89 44 24 0c          	mov    %eax,0xc(%esp)
 8049963:	8d 45 a0             	lea    -0x60(%ebp),%eax
 8049966:	89 44 24 08          	mov    %eax,0x8(%esp)
 804996a:	c7 44 24 04 9b a1 04 	movl   $0x804a19b,0x4(%esp)
 8049971:	08 
 8049972:	c7 04 24 f0 c6 04 08 	movl   $0x804c6f0,(%esp)
 8049979:	e8 8a ee ff ff       	call   8048808 <__isoc99_sscanf@plt>
 804997e:	83 f8 02             	cmp    $0x2,%eax
 8049981:	75 44                	jne    80499c7 <phase_defused+0x95>
 8049983:	c7 44 24 04 a1 a1 04 	movl   $0x804a1a1,0x4(%esp)
 804998a:	08 
 804998b:	8d 45 a4             	lea    -0x5c(%ebp),%eax
 804998e:	89 04 24             	mov    %eax,(%esp)
 8049991:	e8 15 f7 ff ff       	call   80490ab <strings_not_equal>
 8049996:	85 c0                	test   %eax,%eax
 8049998:	75 2d                	jne    80499c7 <phase_defused+0x95>
 804999a:	c7 44 24 04 7c a2 04 	movl   $0x804a27c,0x4(%esp)
 80499a1:	08 
 80499a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 80499a9:	e8 6a ee ff ff       	call   8048818 <__printf_chk@plt>
 80499ae:	c7 44 24 04 a4 a2 04 	movl   $0x804a2a4,0x4(%esp)
 80499b5:	08 
 80499b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 80499bd:	e8 56 ee ff ff       	call   8048818 <__printf_chk@plt>
 80499c2:	e8 d7 f2 ff ff       	call   8048c9e <secret_phase>
 80499c7:	c7 44 24 04 dc a2 04 	movl   $0x804a2dc,0x4(%esp)
 80499ce:	08 
 80499cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 80499d6:	e8 3d ee ff ff       	call   8048818 <__printf_chk@plt>
 80499db:	c7 44 24 04 08 a3 04 	movl   $0x804a308,0x4(%esp)
 80499e2:	08 
 80499e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 80499ea:	e8 29 ee ff ff       	call   8048818 <__printf_chk@plt>
 80499ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80499f2:	65 33 05 14 00 00 00 	xor    %gs:0x14,%eax
 80499f9:	74 05                	je     8049a00 <phase_defused+0xce>
 80499fb:	e8 48 ef ff ff       	call   8048948 <__stack_chk_fail@plt>
 8049a00:	c9                   	leave  
 8049a01:	c3                   	ret    

08049a02 <explode_bomb>:
 8049a02:	55                   	push   %ebp
 8049a03:	89 e5                	mov    %esp,%ebp
 8049a05:	83 ec 18             	sub    $0x18,%esp
 8049a08:	c7 44 24 04 ae a1 04 	movl   $0x804a1ae,0x4(%esp)
 8049a0f:	08 
 8049a10:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049a17:	e8 fc ed ff ff       	call   8048818 <__printf_chk@plt>
 8049a1c:	c7 44 24 04 b8 a1 04 	movl   $0x804a1b8,0x4(%esp)
 8049a23:	08 
 8049a24:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049a2b:	e8 e8 ed ff ff       	call   8048818 <__printf_chk@plt>
 8049a30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 8049a37:	e8 29 fb ff ff       	call   8049565 <send_msg>
 8049a3c:	c7 44 24 04 4c a3 04 	movl   $0x804a34c,0x4(%esp)
 8049a43:	08 
 8049a44:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049a4b:	e8 c8 ed ff ff       	call   8048818 <__printf_chk@plt>
 8049a50:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 8049a57:	e8 3c ef ff ff       	call   8048998 <exit@plt>

08049a5c <read_six_numbers>:
 8049a5c:	55                   	push   %ebp
 8049a5d:	89 e5                	mov    %esp,%ebp
 8049a5f:	83 ec 28             	sub    $0x28,%esp
 8049a62:	8b 45 0c             	mov    0xc(%ebp),%eax
 8049a65:	8d 50 14             	lea    0x14(%eax),%edx
 8049a68:	89 54 24 1c          	mov    %edx,0x1c(%esp)
 8049a6c:	8d 50 10             	lea    0x10(%eax),%edx
 8049a6f:	89 54 24 18          	mov    %edx,0x18(%esp)
 8049a73:	8d 50 0c             	lea    0xc(%eax),%edx
 8049a76:	89 54 24 14          	mov    %edx,0x14(%esp)
 8049a7a:	8d 50 08             	lea    0x8(%eax),%edx
 8049a7d:	89 54 24 10          	mov    %edx,0x10(%esp)
 8049a81:	8d 50 04             	lea    0x4(%eax),%edx
 8049a84:	89 54 24 0c          	mov    %edx,0xc(%esp)
 8049a88:	89 44 24 08          	mov    %eax,0x8(%esp)
 8049a8c:	c7 44 24 04 d0 a1 04 	movl   $0x804a1d0,0x4(%esp)
 8049a93:	08 
 8049a94:	8b 45 08             	mov    0x8(%ebp),%eax
 8049a97:	89 04 24             	mov    %eax,(%esp)
 8049a9a:	e8 69 ed ff ff       	call   8048808 <__isoc99_sscanf@plt>
 8049a9f:	83 f8 05             	cmp    $0x5,%eax
 8049aa2:	7f 05                	jg     8049aa9 <read_six_numbers+0x4d>
 8049aa4:	e8 59 ff ff ff       	call   8049a02 <explode_bomb>
 8049aa9:	c9                   	leave  
 8049aaa:	c3                   	ret    

08049aab <read_line>:
 8049aab:	55                   	push   %ebp
 8049aac:	89 e5                	mov    %esp,%ebp
 8049aae:	57                   	push   %edi
 8049aaf:	53                   	push   %ebx
 8049ab0:	83 ec 10             	sub    $0x10,%esp
 8049ab3:	e8 0e f7 ff ff       	call   80491c6 <skip>
 8049ab8:	85 c0                	test   %eax,%eax
 8049aba:	75 70                	jne    8049b2c <read_line+0x81>
 8049abc:	a1 f0 c5 04 08       	mov    0x804c5f0,%eax
 8049ac1:	3b 05 c0 c5 04 08    	cmp    0x804c5c0,%eax
 8049ac7:	75 1b                	jne    8049ae4 <read_line+0x39>
 8049ac9:	c7 44 24 04 70 a3 04 	movl   $0x804a370,0x4(%esp)
 8049ad0:	08 
 8049ad1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049ad8:	e8 3b ed ff ff       	call   8048818 <__printf_chk@plt>
 8049add:	e8 20 ff ff ff       	call   8049a02 <explode_bomb>
 8049ae2:	eb 48                	jmp    8049b2c <read_line+0x81>
 8049ae4:	c7 04 24 e2 a1 04 08 	movl   $0x804a1e2,(%esp)
 8049aeb:	e8 38 ed ff ff       	call   8048828 <getenv@plt>
 8049af0:	85 c0                	test   %eax,%eax
 8049af2:	74 0c                	je     8049b00 <read_line+0x55>
 8049af4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 8049afb:	e8 98 ee ff ff       	call   8048998 <exit@plt>
 8049b00:	a1 c0 c5 04 08       	mov    0x804c5c0,%eax
 8049b05:	a3 f0 c5 04 08       	mov    %eax,0x804c5f0
 8049b0a:	e8 b7 f6 ff ff       	call   80491c6 <skip>
 8049b0f:	85 c0                	test   %eax,%eax
 8049b11:	75 19                	jne    8049b2c <read_line+0x81>
 8049b13:	c7 44 24 04 70 a3 04 	movl   $0x804a370,0x4(%esp)
 8049b1a:	08 
 8049b1b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049b22:	e8 f1 ec ff ff       	call   8048818 <__printf_chk@plt>
 8049b27:	e8 d6 fe ff ff       	call   8049a02 <explode_bomb>
 8049b2c:	a1 ec c5 04 08       	mov    0x804c5ec,%eax
 8049b31:	8d 04 80             	lea    (%eax,%eax,4),%eax
 8049b34:	c1 e0 04             	shl    $0x4,%eax
 8049b37:	8d b8 00 c6 04 08    	lea    0x804c600(%eax),%edi
 8049b3d:	b8 00 00 00 00       	mov    $0x0,%eax
 8049b42:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
 8049b47:	f2 ae                	repnz scas %es:(%edi),%al
 8049b49:	f7 d1                	not    %ecx
 8049b4b:	8d 59 ff             	lea    -0x1(%ecx),%ebx
 8049b4e:	83 fb 4f             	cmp    $0x4f,%ebx
 8049b51:	75 19                	jne    8049b6c <read_line+0xc1>
 8049b53:	c7 44 24 04 ed a1 04 	movl   $0x804a1ed,0x4(%esp)
 8049b5a:	08 
 8049b5b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049b62:	e8 b1 ec ff ff       	call   8048818 <__printf_chk@plt>
 8049b67:	e8 96 fe ff ff       	call   8049a02 <explode_bomb>
 8049b6c:	a1 ec c5 04 08       	mov    0x804c5ec,%eax
 8049b71:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 8049b78:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 8049b7b:	c1 e1 04             	shl    $0x4,%ecx
 8049b7e:	c6 84 0b ff c5 04 08 	movb   $0x0,0x804c5ff(%ebx,%ecx,1)
 8049b85:	00 
 8049b86:	8d 48 01             	lea    0x1(%eax),%ecx
 8049b89:	89 0d ec c5 04 08    	mov    %ecx,0x804c5ec
 8049b8f:	8d 04 02             	lea    (%edx,%eax,1),%eax
 8049b92:	c1 e0 04             	shl    $0x4,%eax
 8049b95:	05 00 c6 04 08       	add    $0x804c600,%eax
 8049b9a:	83 c4 10             	add    $0x10,%esp
 8049b9d:	5b                   	pop    %ebx
 8049b9e:	5f                   	pop    %edi
 8049b9f:	5d                   	pop    %ebp
 8049ba0:	c3                   	ret    

08049ba1 <open_clientfd>:
 8049ba1:	55                   	push   %ebp
 8049ba2:	89 e5                	mov    %esp,%ebp
 8049ba4:	57                   	push   %edi
 8049ba5:	56                   	push   %esi
 8049ba6:	53                   	push   %ebx
 8049ba7:	83 ec 3c             	sub    $0x3c,%esp
 8049baa:	8b 7d 08             	mov    0x8(%ebp),%edi
 8049bad:	65 a1 14 00 00 00    	mov    %gs:0x14,%eax
 8049bb3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 8049bb6:	31 c0                	xor    %eax,%eax
 8049bb8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
 8049bbf:	00 
 8049bc0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 8049bc7:	00 
 8049bc8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 8049bcf:	e8 f4 ec ff ff       	call   80488c8 <socket@plt>
 8049bd4:	89 c6                	mov    %eax,%esi
 8049bd6:	85 c0                	test   %eax,%eax
 8049bd8:	79 20                	jns    8049bfa <open_clientfd+0x59>
 8049bda:	c7 44 24 04 09 a2 04 	movl   $0x804a209,0x4(%esp)
 8049be1:	08 
 8049be2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049be9:	e8 2a ec ff ff       	call   8048818 <__printf_chk@plt>
 8049bee:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 8049bf5:	e8 9e ed ff ff       	call   8048998 <exit@plt>
 8049bfa:	89 3c 24             	mov    %edi,(%esp)
 8049bfd:	e8 86 ed ff ff       	call   8048988 <gethostbyname@plt>
 8049c02:	85 c0                	test   %eax,%eax
 8049c04:	75 20                	jne    8049c26 <open_clientfd+0x85>
 8049c06:	c7 44 24 04 18 a2 04 	movl   $0x804a218,0x4(%esp)
 8049c0d:	08 
 8049c0e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049c15:	e8 fe eb ff ff       	call   8048818 <__printf_chk@plt>
 8049c1a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 8049c21:	e8 72 ed ff ff       	call   8048998 <exit@plt>
 8049c26:	8d 5d d4             	lea    -0x2c(%ebp),%ebx
 8049c29:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
 8049c2f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
 8049c36:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
 8049c3d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
 8049c44:	66 c7 45 d4 02 00    	movw   $0x2,-0x2c(%ebp)
 8049c4a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
 8049c51:	00 
 8049c52:	8b 50 0c             	mov    0xc(%eax),%edx
 8049c55:	89 54 24 08          	mov    %edx,0x8(%esp)
 8049c59:	8b 40 10             	mov    0x10(%eax),%eax
 8049c5c:	8b 00                	mov    (%eax),%eax
 8049c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
 8049c62:	8d 45 d8             	lea    -0x28(%ebp),%eax
 8049c65:	89 04 24             	mov    %eax,(%esp)
 8049c68:	e8 0b ed ff ff       	call   8048978 <__memmove_chk@plt>
 8049c6d:	0f b7 45 0c          	movzwl 0xc(%ebp),%eax
 8049c71:	66 c1 c8 08          	ror    $0x8,%ax
 8049c75:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
 8049c79:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 8049c80:	00 
 8049c81:	89 5c 24 04          	mov    %ebx,0x4(%esp)
 8049c85:	89 34 24             	mov    %esi,(%esp)
 8049c88:	e8 2b eb ff ff       	call   80487b8 <connect@plt>
 8049c8d:	85 c0                	test   %eax,%eax
 8049c8f:	79 24                	jns    8049cb5 <open_clientfd+0x114>
 8049c91:	89 7c 24 08          	mov    %edi,0x8(%esp)
 8049c95:	c7 44 24 04 27 a2 04 	movl   $0x804a227,0x4(%esp)
 8049c9c:	08 
 8049c9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8049ca4:	e8 6f eb ff ff       	call   8048818 <__printf_chk@plt>
 8049ca9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
 8049cb0:	e8 e3 ec ff ff       	call   8048998 <exit@plt>
 8049cb5:	89 f0                	mov    %esi,%eax
 8049cb7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 8049cba:	65 33 15 14 00 00 00 	xor    %gs:0x14,%edx
 8049cc1:	74 05                	je     8049cc8 <open_clientfd+0x127>
 8049cc3:	e8 80 ec ff ff       	call   8048948 <__stack_chk_fail@plt>
 8049cc8:	83 c4 3c             	add    $0x3c,%esp
 8049ccb:	5b                   	pop    %ebx
 8049ccc:	5e                   	pop    %esi
 8049ccd:	5f                   	pop    %edi
 8049cce:	5d                   	pop    %ebp
 8049ccf:	c3                   	ret    

08049cd0 <initialize_bomb>:
 8049cd0:	55                   	push   %ebp
 8049cd1:	89 e5                	mov    %esp,%ebp
 8049cd3:	83 ec 18             	sub    $0x18,%esp
 8049cd6:	c7 44 24 04 10 92 04 	movl   $0x8049210,0x4(%esp)
 8049cdd:	08 
 8049cde:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 8049ce5:	e8 ee ea ff ff       	call   80487d8 <signal@plt>
 8049cea:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
 8049cf1:	00 
 8049cf2:	c7 04 24 6b a1 04 08 	movl   $0x804a16b,(%esp)
 8049cf9:	e8 a3 fe ff ff       	call   8049ba1 <open_clientfd>
 8049cfe:	89 04 24             	mov    %eax,(%esp)
 8049d01:	e8 22 ec ff ff       	call   8048928 <close@plt>
 8049d06:	c9                   	leave  
 8049d07:	c3                   	ret    
 8049d08:	90                   	nop
 8049d09:	90                   	nop
 8049d0a:	90                   	nop
 8049d0b:	90                   	nop
 8049d0c:	90                   	nop
 8049d0d:	90                   	nop
 8049d0e:	90                   	nop
 8049d0f:	90                   	nop

08049d10 <__libc_csu_fini>:
 8049d10:	55                   	push   %ebp
 8049d11:	89 e5                	mov    %esp,%ebp
 8049d13:	5d                   	pop    %ebp
 8049d14:	c3                   	ret    
 8049d15:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 8049d19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

08049d20 <__libc_csu_init>:
 8049d20:	55                   	push   %ebp
 8049d21:	89 e5                	mov    %esp,%ebp
 8049d23:	57                   	push   %edi
 8049d24:	56                   	push   %esi
 8049d25:	53                   	push   %ebx
 8049d26:	e8 4f 00 00 00       	call   8049d7a <__i686.get_pc_thunk.bx>
 8049d2b:	81 c3 c9 22 00 00    	add    $0x22c9,%ebx
 8049d31:	83 ec 1c             	sub    $0x1c,%esp
 8049d34:	e8 2f ea ff ff       	call   8048768 <_init>
 8049d39:	8d bb 20 ff ff ff    	lea    -0xe0(%ebx),%edi
 8049d3f:	8d 83 20 ff ff ff    	lea    -0xe0(%ebx),%eax
 8049d45:	29 c7                	sub    %eax,%edi
 8049d47:	c1 ff 02             	sar    $0x2,%edi
 8049d4a:	85 ff                	test   %edi,%edi
 8049d4c:	74 24                	je     8049d72 <__libc_csu_init+0x52>
 8049d4e:	31 f6                	xor    %esi,%esi
 8049d50:	8b 45 10             	mov    0x10(%ebp),%eax
 8049d53:	89 44 24 08          	mov    %eax,0x8(%esp)
 8049d57:	8b 45 0c             	mov    0xc(%ebp),%eax
 8049d5a:	89 44 24 04          	mov    %eax,0x4(%esp)
 8049d5e:	8b 45 08             	mov    0x8(%ebp),%eax
 8049d61:	89 04 24             	mov    %eax,(%esp)
 8049d64:	ff 94 b3 20 ff ff ff 	call   *-0xe0(%ebx,%esi,4)
 8049d6b:	83 c6 01             	add    $0x1,%esi
 8049d6e:	39 fe                	cmp    %edi,%esi
 8049d70:	72 de                	jb     8049d50 <__libc_csu_init+0x30>
 8049d72:	83 c4 1c             	add    $0x1c,%esp
 8049d75:	5b                   	pop    %ebx
 8049d76:	5e                   	pop    %esi
 8049d77:	5f                   	pop    %edi
 8049d78:	5d                   	pop    %ebp
 8049d79:	c3                   	ret    

08049d7a <__i686.get_pc_thunk.bx>:
 8049d7a:	8b 1c 24             	mov    (%esp),%ebx
 8049d7d:	c3                   	ret    
 8049d7e:	90                   	nop
 8049d7f:	90                   	nop

08049d80 <__do_global_ctors_aux>:
 8049d80:	55                   	push   %ebp
 8049d81:	89 e5                	mov    %esp,%ebp
 8049d83:	53                   	push   %ebx
 8049d84:	83 ec 04             	sub    $0x4,%esp
 8049d87:	a1 14 bf 04 08       	mov    0x804bf14,%eax
 8049d8c:	83 f8 ff             	cmp    $0xffffffff,%eax
 8049d8f:	74 13                	je     8049da4 <__do_global_ctors_aux+0x24>
 8049d91:	bb 14 bf 04 08       	mov    $0x804bf14,%ebx
 8049d96:	66 90                	xchg   %ax,%ax
 8049d98:	83 eb 04             	sub    $0x4,%ebx
 8049d9b:	ff d0                	call   *%eax
 8049d9d:	8b 03                	mov    (%ebx),%eax
 8049d9f:	83 f8 ff             	cmp    $0xffffffff,%eax
 8049da2:	75 f4                	jne    8049d98 <__do_global_ctors_aux+0x18>
 8049da4:	83 c4 04             	add    $0x4,%esp
 8049da7:	5b                   	pop    %ebx
 8049da8:	5d                   	pop    %ebp
 8049da9:	c3                   	ret    
 8049daa:	90                   	nop
 8049dab:	90                   	nop

Disassembly of section .fini:

08049dac <_fini>:
 8049dac:	55                   	push   %ebp
 8049dad:	89 e5                	mov    %esp,%ebp
 8049daf:	53                   	push   %ebx
 8049db0:	83 ec 04             	sub    $0x4,%esp
 8049db3:	e8 00 00 00 00       	call   8049db8 <_fini+0xc>
 8049db8:	5b                   	pop    %ebx
 8049db9:	81 c3 3c 22 00 00    	add    $0x223c,%ebx
 8049dbf:	e8 1c ec ff ff       	call   80489e0 <__do_global_dtors_aux>
 8049dc4:	59                   	pop    %ecx
 8049dc5:	5b                   	pop    %ebx
 8049dc6:	c9                   	leave  
 8049dc7:	c3                   	ret    
